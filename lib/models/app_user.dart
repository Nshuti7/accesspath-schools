class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.schoolId,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final String schoolId;

  /// Either 'admin' (created the school) or 'staff'.
  final String role;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      schoolId: map['schoolId'] as String? ?? '',
      role: map['role'] as String? ?? 'staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'schoolId': schoolId, 'role': role};
  }
}
