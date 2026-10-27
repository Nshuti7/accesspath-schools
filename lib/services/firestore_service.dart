import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/school.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Creates the school and its first (admin) user together, so we never end
  /// up with a user pointing at a school that does not exist.
  Future<void> createSchoolWithAdmin({
    required String uid,
    required String name,
    required String email,
    required String schoolName,
  }) async {
    final schoolRef = _db.collection('schools').doc();
    final school = School(id: schoolRef.id, name: schoolName, createdBy: uid);
    final user = AppUser(
      uid: uid,
      name: name,
      email: email,
      schoolId: schoolRef.id,
      role: 'admin',
    );

    final batch = _db.batch();
    batch.set(schoolRef, school.toMap());
    batch.set(_db.collection('users').doc(uid), user.toMap());
    await batch.commit();
  }
}
