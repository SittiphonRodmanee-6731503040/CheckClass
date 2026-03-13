import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/class_model.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ─── Classes ───

  Future<String> createClass(ClassModel classModel) async {
    final doc = _db.collection('classes').doc();
    await doc.set(classModel.toMap());
    return doc.id;
  }

  Stream<List<ClassModel>> getInstructorClasses(String instructorId) {
    return _db
        .collection('classes')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ClassModel.fromSnapshot(doc)).toList(),
        );
  }

  Future<ClassModel?> getClass(String classId) async {
    final doc = await _db.collection('classes').doc(classId).get();
    if (doc.exists) return ClassModel.fromSnapshot(doc);
    return null;
  }

  Future<void> updateClass(String classId, Map<String, dynamic> data) {
    return _db.collection('classes').doc(classId).update(data);
  }

  Future<void> deleteClass(String classId) {
    return _db.collection('classes').doc(classId).delete();
  }

  // ─── Sessions ───

  Future<String> createSession(String classId) async {
    final qrData = _uuid.v4();
    final session = SessionModel(
      id: '',
      classId: classId,
      date: DateTime.now(),
      qrCodeData: qrData,
      status: 'open',
    );
    final doc = _db.collection('sessions').doc();
    await doc.set(session.toMap());
    return doc.id;
  }

  Future<SessionModel?> getSession(String sessionId) async {
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (doc.exists) return SessionModel.fromSnapshot(doc);
    return null;
  }

  Stream<List<SessionModel>> getClassSessions(String classId) {
    return _db
        .collection('sessions')
        .where('classId', isEqualTo: classId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => SessionModel.fromSnapshot(doc)).toList(),
        );
  }

  Stream<SessionModel?> getActiveSession(String classId) {
    return _db
        .collection('sessions')
        .where('classId', isEqualTo: classId)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.isNotEmpty
                  ? SessionModel.fromSnapshot(snap.docs.first)
                  : null,
        );
  }

  Future<SessionModel?> findSessionByQrCode(String qrData) async {
    final snap =
        await _db
            .collection('sessions')
            .where('qrCodeData', isEqualTo: qrData)
            .where('status', isEqualTo: 'open')
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) return SessionModel.fromSnapshot(snap.docs.first);
    return null;
  }

  Future<void> closeSession(String sessionId) async {
    // Close the session
    await _db.collection('sessions').doc(sessionId).update({
      'status': 'closed',
    });

    // Flag all checked-in (but not completed) attendance as 'incomplete'
    await _flagIncompleteAttendance(sessionId);
  }

  // Mark attendance records without checkout as 'incomplete'
  Future<void> _flagIncompleteAttendance(String sessionId) async {
    final snap = await _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'checked-in')
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'status': 'incomplete'});
    }
    await batch.commit();
  }

  // Check and auto-close expired sessions (30 min after creation)
  Future<void> closeExpiredSessions() async {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 30));
    final snap = await _db
        .collection('sessions')
        .where('status', isEqualTo: 'open')
        .where('date', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    for (final doc in snap.docs) {
      await closeSession(doc.id);
    }
  }

  // ─── Attendance ───

  Future<String> checkIn(AttendanceModel attendance) async {
    final doc = _db.collection('attendance').doc();
    await doc.set(attendance.toCheckInMap());
    return doc.id;
  }

  Future<void> checkOut(String attendanceId, AttendanceModel attendance) {
    return _db
        .collection('attendance')
        .doc(attendanceId)
        .update(attendance.toCheckOutMap());
  }

  Future<AttendanceModel?> getStudentAttendance(
    String sessionId,
    String studentId,
  ) async {
    final snap =
        await _db
            .collection('attendance')
            .where('sessionId', isEqualTo: sessionId)
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      return AttendanceModel.fromSnapshot(snap.docs.first);
    }
    return null;
  }

  Stream<List<AttendanceModel>> getSessionAttendance(String sessionId) {
    return _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => AttendanceModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  Stream<List<AttendanceModel>> getStudentHistory(String studentId) {
    return _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('checkIn.timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => AttendanceModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  // Get all open sessions (for student home)
  Stream<List<SessionModel>> getAllOpenSessions() {
    return _db
        .collection('sessions')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => SessionModel.fromSnapshot(doc)).toList(),
        );
  }
}
