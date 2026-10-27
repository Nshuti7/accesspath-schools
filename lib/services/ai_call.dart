import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';

enum AiError { offline, quotaReached, unreadableResponse, unavailable }

class AiException implements Exception {
  const AiException(this.reason);

  final AiError reason;

  @override
  String toString() => 'AiException($reason)';
}

/// Stable Flash model on the Gemini Developer API, with no shutdown before
/// May 2027. The 3.6-3.8 Flash models are marked short-term, so avoid them.
const geminiModelName = 'gemini-3.5-flash';

const _timeout = Duration(seconds: 60);

/// Sends one Gemini request and returns its text. Every way it can fail is
/// turned into an [AiException], so screens only handle four friendly cases.
Future<String> runAiCall(
  Future<GenerateContentResponse> Function() request,
) async {
  final GenerateContentResponse response;
  try {
    response = await request().timeout(_timeout);
  } on QuotaExceeded {
    throw const AiException(AiError.quotaReached);
  } on ServerException catch (error) {
    // Rate limits sometimes arrive as a plain server error instead of
    // QuotaExceeded.
    final isRateLimit =
        error.message.contains('RESOURCE_EXHAUSTED') ||
        error.message.contains('429');
    throw AiException(isRateLimit ? AiError.quotaReached : AiError.unavailable);
  } on FirebaseAIException {
    throw const AiException(AiError.unavailable);
  } on FirebaseAISdkException {
    throw const AiException(AiError.unreadableResponse);
  } catch (_) {
    // Network failures come through as http/socket exceptions, which differ
    // between Android and web, plus our own timeout.
    throw const AiException(AiError.offline);
  }

  final String? text;
  try {
    text = response.text;
  } catch (_) {
    // Thrown when the response was blocked, e.g. by a safety filter.
    throw const AiException(AiError.unreadableResponse);
  }
  if (text == null || text.trim().isEmpty) {
    throw const AiException(AiError.unreadableResponse);
  }
  return text;
}
