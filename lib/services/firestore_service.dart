import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/answer.dart';
import '../models/app_user.dart';
import '../models/school.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _answersOf(String schoolId) {
    return _db.collection('schools').doc(schoolId).collection('answers');
  }

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

  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    final data = snapshot.data();
    return data == null ? null : AppUser.fromMap(uid, data);
  }

  Future<List<Answer>> loadAnswers(String schoolId) async {
    final snapshot = await _answersOf(schoolId).get();
    return snapshot.docs
        .map((doc) => Answer.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> saveAnswer(String schoolId, Answer answer) {
    // Merge, and leave out `note`, so changing the answer never wipes a note
    // someone added separately.
    return _answersOf(schoolId).doc(answer.itemId).set({
      'area': answer.area,
      'answer': answer.value.name,
      'updatedBy': answer.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
