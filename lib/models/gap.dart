/// A barrier the school has recorded, stored at schools/{schoolId}/gaps/{gapId}.
class Gap {
  const Gap({
    required this.id,
    required this.itemId,
    required this.area,
    required this.title,
    required this.priority,
    required this.source,
    this.aiDescription = '',
    this.status = 'open',
  });

  final String id;
  final String itemId;
  final String area;
  final String title;

  /// 'high', 'medium' or 'low'.
  final String priority;

  /// 'checklist' or 'ai_photo'.
  final String source;

  /// What Gemini saw, for gaps from a photo check. Empty otherwise.
  final String aiDescription;

  /// 'open', 'verified' or 'resolved'.
  final String status;

  factory Gap.fromMap(String id, Map<String, dynamic> map) {
    return Gap(
      id: id,
      itemId: map['itemId'] as String? ?? '',
      area: map['area'] as String? ?? '',
      title: map['title'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      source: map['source'] as String? ?? 'checklist',
      aiDescription: map['aiDescription'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
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
