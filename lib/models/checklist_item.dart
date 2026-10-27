/// One question from the accessibility checklist, loaded from
/// assets/data/checklist.json.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.area,
    required this.question,
    required this.whyItMatters,
    required this.guideRef,
    required this.defaultPriority,
    this.isRecommendation = false,
  });

  final String id;

  /// One of the six assessment areas, e.g. 'ramps_pathways'.
  final String area;
  final String question;
  final String whyItMatters;

  /// Printed page number in the Ministry guide, or 'TODO' if not yet confirmed.
  final String guideRef;

  /// 'high', 'medium' or 'low'.
  final String defaultPriority;

  /// True when the guide marks this as a Ministry recommendation rather than
  /// a building-code requirement, so the app can word gaps more softly.
  final bool isRecommendation;

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      area: map['area'] as String,
      question: map['question'] as String,
      whyItMatters: map['whyItMatters'] as String? ?? '',
      guideRef: map['guideRef'] as String? ?? 'TODO',
      defaultPriority: map['defaultPriority'] as String? ?? 'medium',
      isRecommendation: map['isRecommendation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area': area,
      'question': question,
      'whyItMatters': whyItMatters,
      'guideRef': guideRef,
      'defaultPriority': defaultPriority,
      'isRecommendation': isRecommendation,
    };
  }
}
