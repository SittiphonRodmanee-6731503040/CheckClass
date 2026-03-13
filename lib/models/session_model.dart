import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String classId;
  final DateTime date;
  final String qrCodeData;
  final String status; // 'open' or 'closed'

  SessionModel({
    required this.id,
    required this.classId,
    required this.date,
    required this.qrCodeData,
    this.status = 'open',
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      classId: map['classId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      qrCodeData: map['qrCodeData'] ?? '',
      status: map['status'] ?? 'open',
    );
  }

  factory SessionModel.fromSnapshot(DocumentSnapshot doc) {
    return SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'qrCodeData': qrCodeData,
      'status': status,
    };
  }

  bool get isOpen => status == 'open';
}
