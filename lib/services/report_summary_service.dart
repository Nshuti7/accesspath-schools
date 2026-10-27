import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../models/action_item.dart';
import '../models/assessment_area.dart';
import '../models/assessment_stats.dart';
import '../models/checklist_item.dart';
import '../models/gap.dart';
import '../models/report_summary.dart';
import 'ai_call.dart';

class ReportSummaryService {
  static const _systemInstruction = '''
You write a short summary of a school's accessibility gap report for the
headteacher of a school in Uganda. The report comes from a self-assessment
using the Ministry of Education and Sports School Accessibility Companion
Guide. You receive the report as JSON.

Write:
- overview: 2 or 3 sentences on the overall status: how much of the checklist
  is answered, the score, and how many gaps are open or still need checking.
  The score is the share of answered questions marked "yes"; say so if you
  mention it.
- priorities: the top 3 gaps to fix first (fewer if there are fewer gaps).
  Prefer high priority, then gaps that are confirmed over ones that need
  checking. For each, a short title and one sentence on why it matters for
  learners, using the gap's question and recommendation.
- nextSteps: 2 to 4 short, practical steps, such as fixing the top gaps,
  assigning owners, following up overdue actions, or finishing unanswered
  areas.

Rules:
- Use only the data given. Do not add standards, measurements or facts.
- Cite guide pages only when they appear in the data, written like
  "(Guide p. 12)". Never invent a page. Skip a page marked "TODO".
- Gaps with status "needs checking" are possible issues; say they need to be
  checked, not that they are confirmed.
- Never say the school is compliant, accessible, certified or approved, even
  if there are no gaps. If there are no open gaps, say the assessment found
  none so far and suggest keeping the assessment up to date.
- Plain English for a busy headteacher. No jargon, no Markdown symbols.''';

  Future<ReportSummary> summarise({
    required String schoolName,
    required AssessmentStats stats,
    required List<Gap> gaps,
    required ChecklistItem? Function(String itemId) itemById,
    required List<ActionItem> actions,
    required DateTime now,
  }) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: geminiModelName,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _summarySchema,
      ),
    );
    final data = buildReportData(
      schoolName: schoolName,
      stats: stats,
      gaps: gaps,
      itemById: itemById,
      actions: actions,
      now: now,
    );
    final text = await runAiCall(
      () => model.generateContent([Content.text(jsonEncode(data))]),
    );
    return parseSummary(text);
  }

  static final _summarySchema = Schema.object(
    properties: {
      'overview': Schema.string(),
      'priorities': Schema.array(
        items: Schema.object(
          properties: {'title': Schema.string(), 'reason': Schema.string()},
        ),
      ),
      'nextSteps': Schema.array(items: Schema.string()),
    },
    propertyOrdering: ['overview', 'priorities', 'nextSteps'],
  );

  /// The only data sent to Gemini: no staff names other than action owners,
  /// no emails and no photos.
  @visibleForTesting
  static Map<String, Object?> buildReportData({
    required String schoolName,
    required AssessmentStats stats,
    required List<Gap> gaps,
    required ChecklistItem? Function(String itemId) itemById,
    required List<ActionItem> actions,
    required DateTime now,
  }) {
    final gapsById = {for (final gap in gaps) gap.id: gap};
    return {
      'schoolName': schoolName,
      'questionsAnswered': stats.answeredCount,
      'questionsTotal': stats.totalItems,
      'scorePercent': stats.scorePercent,
      'openGaps': stats.openGaps,
      'gapsNeedingChecks': stats.needsVerificationGaps,
      'resolvedGaps': stats.resolvedGaps,
      'gaps': [
        for (final gap in gaps.where((gap) => !gap.isResolved))
          {
            'priority': gap.priority,
            'area': AssessmentArea.byId(gap.area)?.name ?? gap.area,
            'question': itemById(gap.itemId)?.question ?? gap.title,
            'recommendation': itemById(gap.itemId)?.recommendation ?? '',
            'guidePage': itemById(gap.itemId)?.guideRef ?? 'TODO',
            'status': gap.status == Gap.statusNeedsVerification
                ? 'needs checking'
                : 'confirmed',
          },
      ],
      'overdueActions': [
        for (final action in actions.where((a) => a.isOverdueOn(now)))
          {
            'title': action.title,
            'owner': action.ownerName,
            'dueDate': action.dueDate.toIso8601String().substring(0, 10),
            'gapArea': AssessmentArea.byId(gapsById[action.gapId]?.area ?? '')
                ?.name,
          },
      ],
    };
  }

  /// Reads Gemini's JSON reply. Throws [AiException] if it has no overview;
  /// skips malformed priorities and steps.
  @visibleForTesting
  static ReportSummary parseSummary(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const AiException(AiError.unreadableResponse);
    }
    if (decoded is! Map) throw const AiException(AiError.unreadableResponse);

    final overview = decoded['overview'];
    if (overview is! String || overview.trim().isEmpty) {
      throw const AiException(AiError.unreadableResponse);
    }

    final priorities = <({String title, String reason})>[];
    final rawPriorities = decoded['priorities'];
    if (rawPriorities is List) {
      for (final entry in rawPriorities) {
        if (entry is! Map) continue;
        final title = entry['title'];
        final reason = entry['reason'];
        if (title is! String || title.trim().isEmpty) continue;
        priorities.add((
          title: title.trim(),
          reason: reason is String ? reason.trim() : '',
        ));
      }
    }

    final rawSteps = decoded['nextSteps'];
    final nextSteps = [
      if (rawSteps is List)
        for (final step in rawSteps)
          if (step is String && step.trim().isNotEmpty) step.trim(),
    ];

    return ReportSummary(
      overview: overview.trim(),
      // The prompt asks for three; never show more even if it sends more.
      priorities: priorities.take(3).toList(),
      nextSteps: nextSteps,
    );
  }
}
