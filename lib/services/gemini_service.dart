import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../models/checklist_item.dart';
import '../models/photo_finding.dart';

enum PhotoCheckError { offline, quotaReached, unreadableResponse, unavailable }

class PhotoCheckException implements Exception {
  const PhotoCheckException(this.reason);

  final PhotoCheckError reason;

  @override
  String toString() => 'PhotoCheckException($reason)';
}

class GeminiService {
  // Stable Flash model on the Gemini Developer API, with no shutdown before
  // May 2027. The 3.6-3.8 Flash models are marked short-term, so avoid them.
  static const modelName = 'gemini-3.5-flash';

  static const _timeout = Duration(seconds: 60);
  static const _confidenceLevels = ['low', 'medium', 'high'];

  static const _systemInstruction = '''
You help school staff in Uganda look for possible physical accessibility
barriers in photos of their school, using checklist items from the Ministry of
Education and Sports School Accessibility Companion Guide (2024).

You receive one photo and a list of checklist items, each with an id and a
yes/no question. For each item, decide whether something visible in the photo
suggests the answer could be "No".

Rules:
- Only report an item when you can point to something in the photo. Do not
  report items about things the photo does not show.
- Never say that anything is compliant, accessible, safe or certified. You are
  only flagging possible issues for a person to check.
- Do not state exact measurements. If size matters, describe it relative to
  something visible, for example "the door looks narrower than the wheelchair
  next to it".
- Write each finding in one or two short, plain sentences: what you see and
  where it is in the photo.
- Set confidence to "high" only when the barrier is clearly visible, "medium"
  when it is likely, and "low" when it is unclear.
- If the photo shows no possible barriers for these items, or is not a photo
  of a school building or grounds, return an empty list.''';

  Future<List<PhotoFinding>> checkPhoto({
    required Uint8List imageBytes,
    required String mimeType,
    required List<ChecklistItem> items,
  }) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: modelName,
      systemInstruction: Content('system', [TextPart(_systemInstruction)]),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _findingsSchema(items),
      ),
    );

    final itemList = items
        .map((item) => '- ${item.id}: ${item.question}')
        .join('\n');
    final prompt = Content.multi([
      TextPart('Checklist items:\n$itemList'),
      InlineDataPart(mimeType, imageBytes),
    ]);

    final GenerateContentResponse response;
    try {
      response = await model.generateContent([prompt]).timeout(_timeout);
    } on QuotaExceeded {
      throw const PhotoCheckException(PhotoCheckError.quotaReached);
    } on ServerException catch (error) {
      // Rate limits sometimes arrive as a plain server error instead of
      // QuotaExceeded.
      final isRateLimit =
          error.message.contains('RESOURCE_EXHAUSTED') ||
          error.message.contains('429');
      throw PhotoCheckException(
        isRateLimit
            ? PhotoCheckError.quotaReached
            : PhotoCheckError.unavailable,
      );
    } on FirebaseAIException {
      throw const PhotoCheckException(PhotoCheckError.unavailable);
    } on FirebaseAISdkException {
      throw const PhotoCheckException(PhotoCheckError.unreadableResponse);
    } catch (_) {
      // Network failures come through as http/socket exceptions, which differ
      // between Android and web, plus our own timeout.
      throw const PhotoCheckException(PhotoCheckError.offline);
    }

    final String? text;
    try {
      text = response.text;
    } catch (_) {
      // Thrown when the response was blocked, e.g. by a safety filter.
      throw const PhotoCheckException(PhotoCheckError.unreadableResponse);
    }
    return parseFindings(text, items.map((item) => item.id).toSet());
  }

  /// Some pickers (notably on Android) do not report a MIME type, so fall back
  /// to the file extension. Resized photos are JPEG unless they were PNG/WebP.
  static String imageMimeType(String? reported, String fileName) {
    if (reported != null && reported.startsWith('image/')) return reported;
    final name = fileName.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  /// The itemId is an enum of the ids we sent, so Gemini cannot make up
  /// checklist items that do not exist.
  Schema _findingsSchema(List<ChecklistItem> items) {
    return Schema.array(
      items: Schema.object(
        properties: {
          'itemId': Schema.enumString(
            enumValues: items.map((item) => item.id).toList(),
          ),
          'finding': Schema.string(),
          'confidence': Schema.enumString(enumValues: _confidenceLevels),
        },
        propertyOrdering: ['itemId', 'finding', 'confidence'],
      ),
    );
  }

  /// Reads Gemini's JSON reply. Throws [PhotoCheckException] if the reply is
  /// not a list at all; skips any single entry that is malformed.
  @visibleForTesting
  static List<PhotoFinding> parseFindings(String? text, Set<String> validIds) {
    if (text == null || text.trim().isEmpty) {
      throw const PhotoCheckException(PhotoCheckError.unreadableResponse);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const PhotoCheckException(PhotoCheckError.unreadableResponse);
    }
    if (decoded is! List) {
      throw const PhotoCheckException(PhotoCheckError.unreadableResponse);
    }

    final findings = <PhotoFinding>[];
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final itemId = entry['itemId'];
      final finding = entry['finding'];
      final confidence = entry['confidence'];
      if (itemId is! String || !validIds.contains(itemId)) continue;
      if (finding is! String || finding.trim().isEmpty) continue;
      findings.add(
        PhotoFinding(
          itemId: itemId,
          finding: finding.trim(),
          confidence: _confidenceLevels.contains(confidence)
              ? confidence as String
              : 'low',
        ),
      );
    }
    return findings;
  }
}
