enum AnswerValue { yes, no, unsure }

/// A school's answer to one checklist item, stored at
/// schools/{schoolId}/answers/{itemId}.
class Answer {
  const Answer({
    required this.itemId,
    required this.area,
    required this.value,
    required this.updatedBy,
    this.note = '',
  });

  final String itemId;
  final String area;
  final AnswerValue value;
  final String updatedBy;
  final String note;

  factory Answer.fromMap(String itemId, Map<String, dynamic> map) {
    return Answer(
      itemId: itemId,
      area: map['area'] as String? ?? '',
      value: AnswerValue.values.byName(map['answer'] as String),
      updatedBy: map['updatedBy'] as String? ?? '',
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'answer': value.name,
      'note': note,
      'updatedBy': updatedBy,
    };
  }
}
