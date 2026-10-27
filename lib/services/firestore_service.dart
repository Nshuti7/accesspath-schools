import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/action_item.dart';
import '../models/answer.dart';
import '../models/app_user.dart';
import '../models/gap.dart';
import '../models/school.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _answersOf(String schoolId) {
    return _db.collection('schools').doc(schoolId).collection('answers');
  }

  CollectionReference<Map<String, dynamic>> _gapsOf(String schoolId) {
    return _db.collection('schools').doc(schoolId).collection('gaps');
  }

  CollectionReference<Map<String, dynamic>> _actionsOf(String schoolId) {
    return _db.collection('schools').doc(schoolId).collection('actions');
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

  Future<List<Gap>> loadGaps(String schoolId) async {
    final snapshot = await _gapsOf(schoolId).get();
    return snapshot.docs.map((doc) => Gap.fromMap(doc.id, doc.data())).toList();
  }

  /// Adds a gap with a generated id and returns that id.
  Future<String> addGap(String schoolId, Gap gap) async {
    final ref = await _gapsOf(schoolId).add(gap.toMap());
    return ref.id;
  }

  Future<void> updateGapStatus(String schoolId, String gapId, String status) {
    return _gapsOf(schoolId).doc(gapId).update({'status': status});
  }

  Future<List<ActionItem>> loadActions(String schoolId) async {
    final snapshot = await _actionsOf(schoolId).get();
    return snapshot.docs
        .map((doc) => ActionItem.fromMap(doc.id, _withDates(doc.data())))
        .toList();
  }

  /// Adds an action with a generated id and returns that id.
  Future<String> addAction(String schoolId, ActionItem action) async {
    final ref = await _actionsOf(schoolId)
        .add({...action.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  }

  Future<void> updateActionStatus(
    String schoolId,
    String actionId,
    String status,
  ) {
    return _actionsOf(schoolId).doc(actionId).update({'status': status});
  }

  /// Firestore returns Timestamps; models work with plain DateTime.
  static Map<String, dynamic> _withDates(Map<String, dynamic> data) {
    return data.map(
      (key, value) =>
          MapEntry(key, value is Timestamp ? value.toDate() : value),
    );
  }

  /// Saves the answer and, if given, its checklist gap in one batch, so the
  /// gap report can never disagree with the answers.
  Future<void> saveAnswer(String schoolId, Answer answer, {Gap? checklistGap}) {
    final batch = _db.batch();
    // Merge, and leave out `note`, so changing the answer never wipes a note
    // someone added separately.
    batch.set(_answersOf(schoolId).doc(answer.itemId), {
      'area': answer.area,
      'answer': answer.value.name,
      'updatedBy': answer.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (checklistGap != null) {
      // Merge so fields added later (e.g. by the action tracker) survive.
      batch.set(
        _gapsOf(schoolId).doc(checklistGap.id),
        checklistGap.toMap(),
        SetOptions(merge: true),
      );
    }
    return batch.commit();
  }
}
