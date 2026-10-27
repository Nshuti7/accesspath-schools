class School {
  const School({
    required this.id,
    required this.name,
    required this.createdBy,
    this.district = '',
    this.type = '',
    this.score = 0,
  });

  static const typePrimary = 'primary';
  static const typeSecondary = 'secondary';
  static const typeBoth = 'both';
  static const types = [typePrimary, typeSecondary, typeBoth];

  final String id;
  final String name;
  final String createdBy;

  final String district;

  /// One of [types]. Empty for schools created before it was asked.
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

  School copyWith({String? name, String? district, String? type}) {
    return School(
      id: id,
      name: name ?? this.name,
      createdBy: createdBy,
      district: district ?? this.district,
      type: type ?? this.type,
      score: score,
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
