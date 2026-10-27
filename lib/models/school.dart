class School {
  const School({
    required this.id,
    required this.name,
    required this.createdBy,
    this.district = '',
    this.type = '',
    this.score = 0,
  });

  final String id;
  final String name;
  final String createdBy;

  // District and type start empty and are filled in on the School setup screen.
  final String district;

  /// Either 'primary' or 'secondary'.
  final String type;

  /// Percentage of answered checklist items marked "yes" (0 to 100).
  final int score;

  factory School.fromMap(String id, Map<String, dynamic> map) {
    return School(
      id: id,
      name: map['name'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      district: map['district'] as String? ?? '',
      type: map['type'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'district': district,
      'type': type,
      'score': score,
    };
  }
}
