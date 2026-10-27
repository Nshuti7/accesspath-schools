import 'answer.dart';
import 'checklist_item.dart';

/// A barrier the school has recorded, stored at schools/{schoolId}/gaps/{gapId}.
///
/// Checklist gaps use the item id as their doc id, so each item has at most
/// one. Photo gaps get a generated id, so several photos can flag one item.
class Gap {
  const Gap({
    required this.id,
    required this.itemId,
    required this.area,
    required this.title,
    required this.priority,
    required this.source,
    this.aiDescription = '',
    this.status = statusOpen,
  });

  static const statusOpen = 'open';
  static const statusNeedsVerification = 'needs_verification';
  static const statusVerified = 'verified';
  static const statusResolved = 'resolved';

  static const sourceChecklist = 'checklist';
  static const sourceAiPhoto = 'ai_photo';

  final String id;
  final String itemId;
  final String area;
  final String title;

  /// 'high', 'medium' or 'low'.
  final String priority;

  /// [sourceChecklist] or [sourceAiPhoto].
  final String source;

  /// What Gemini saw, for gaps from a photo check. Empty otherwise.
  final String aiDescription;

  /// One of the status constants above.
  final String status;

  bool get isResolved => status == statusResolved;

  /// What the checklist gap for [item] should become after it is answered
  /// [value], given the [existing] checklist gap (if any). Returns null when
  /// nothing needs to be written.
  static Gap? afterChecklistAnswer({
    required ChecklistItem item,
    required AnswerValue value,
    required Gap? existing,
  }) {
    final String newStatus;
    switch (value) {
      case AnswerValue.yes:
        // A "Yes" with no earlier gap is the normal case: nothing to resolve.
        if (existing == null) return null;
        newStatus = statusResolved;
      case AnswerValue.no:
        // Keep a gap someone has already verified rather than downgrading it.
        newStatus = existing?.status == statusVerified
            ? statusVerified
            : statusOpen;
      case AnswerValue.unsure:
        newStatus = statusNeedsVerification;
    }

    if (existing == null) {
      return Gap(
        id: item.id,
        itemId: item.id,
        area: item.area,
        title: item.question,
        priority: item.defaultPriority,
        source: sourceChecklist,
        status: newStatus,
      );
    }
    if (existing.status == newStatus) return null;
    return existing.copyWith(status: newStatus);
  }

  Gap copyWith({String? id, String? status}) {
    return Gap(
      id: id ?? this.id,
      itemId: itemId,
      area: area,
      title: title,
      priority: priority,
      source: source,
      aiDescription: aiDescription,
      status: status ?? this.status,
    );
  }

  factory Gap.fromMap(String id, Map<String, dynamic> map) {
    return Gap(
      id: id,
      itemId: map['itemId'] as String? ?? '',
      area: map['area'] as String? ?? '',
      title: map['title'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      source: map['source'] as String? ?? sourceChecklist,
      aiDescription: map['aiDescription'] as String? ?? '',
      status: map['status'] as String? ?? statusOpen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'area': area,
      'title': title,
      'priority': priority,
      'source': source,
      'aiDescription': aiDescription,
      'status': status,
    };
  }
}
