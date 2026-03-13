import 'package:cloud_firestore/cloud_firestore.dart';

class GpsData {
  final double lat;
  final double lng;

  GpsData({required this.lat, required this.lng});

  factory GpsData.fromMap(Map<String, dynamic> map) {
    return GpsData(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {'lat': lat, 'lng': lng};
}

class PreReflection {
  final String previousTopic;
  final String expectedTopic;
  final int mood; // 1-5

  PreReflection({
    required this.previousTopic,
    required this.expectedTopic,
    required this.mood,
  });

  factory PreReflection.fromMap(Map<String, dynamic> map) {
    return PreReflection(
      previousTopic: map['previousTopic'] ?? '',
      expectedTopic: map['expectedTopic'] ?? '',
      mood: (map['mood'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toMap() => {
    'previousTopic': previousTopic,
    'expectedTopic': expectedTopic,
    'mood': mood,
  };
}

class PostReflection {
  final String learningSummary;
  final String feedback;

  PostReflection({required this.learningSummary, required this.feedback});

  factory PostReflection.fromMap(Map<String, dynamic> map) {
    return PostReflection(
      learningSummary: map['learningSummary'] ?? '',
      feedback: map['feedback'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'learningSummary': learningSummary,
    'feedback': feedback,
  };
}

class AttendanceModel {
  final String id;
  final String sessionId;
  final String classId;
  final String studentId;

  // Check-in data
  final GpsData? checkInGps;
  final DateTime? checkInTimestamp;
  final bool checkInQrVerified;

  // Pre-class reflection
  final PreReflection? preReflection;

  // Check-out data
  final GpsData? checkOutGps;
  final DateTime? checkOutTimestamp;
  final bool checkOutQrVerified;

  // Post-class reflection
  final PostReflection? postReflection;

  // Status: 'checked-in', 'complete', 'incomplete'
  final String status;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.classId,
    required this.studentId,
    this.checkInGps,
    this.checkInTimestamp,
    this.checkInQrVerified = false,
    this.preReflection,
    this.checkOutGps,
    this.checkOutTimestamp,
    this.checkOutQrVerified = false,
    this.postReflection,
    this.status = 'checked-in',
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    final checkIn = map['checkIn'] as Map<String, dynamic>? ?? {};
    final checkOut = map['checkOut'] as Map<String, dynamic>? ?? {};
    final preRef = map['preReflection'] as Map<String, dynamic>?;
    final postRef = map['postReflection'] as Map<String, dynamic>?;

    return AttendanceModel(
      id: id,
      sessionId: map['sessionId'] ?? '',
      classId: map['classId'] ?? '',
      studentId: map['studentId'] ?? '',
      checkInGps:
          checkIn['gps'] != null
              ? GpsData.fromMap(checkIn['gps'] as Map<String, dynamic>)
              : null,
      checkInTimestamp: (checkIn['timestamp'] as Timestamp?)?.toDate(),
      checkInQrVerified: checkIn['qrVerified'] ?? false,
      preReflection: preRef != null ? PreReflection.fromMap(preRef) : null,
      checkOutGps:
          checkOut['gps'] != null
              ? GpsData.fromMap(checkOut['gps'] as Map<String, dynamic>)
              : null,
      checkOutTimestamp: (checkOut['timestamp'] as Timestamp?)?.toDate(),
      checkOutQrVerified: checkOut['qrVerified'] ?? false,
      postReflection: postRef != null ? PostReflection.fromMap(postRef) : null,
      status: map['status'] ?? 'checked-in',
    );
  }

  factory AttendanceModel.fromSnapshot(DocumentSnapshot doc) {
    return AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toCheckInMap() {
    return {
      'sessionId': sessionId,
      'classId': classId,
      'studentId': studentId,
      'checkIn': {
        'gps': checkInGps?.toMap(),
        'timestamp':
            checkInTimestamp != null
                ? Timestamp.fromDate(checkInTimestamp!)
                : FieldValue.serverTimestamp(),
        'qrVerified': checkInQrVerified,
      },
      'preReflection': preReflection?.toMap(),
      'status': 'checked-in',
    };
  }

  Map<String, dynamic> toCheckOutMap() {
    return {
      'checkOut': {
        'gps': checkOutGps?.toMap(),
        'timestamp':
            checkOutTimestamp != null
                ? Timestamp.fromDate(checkOutTimestamp!)
                : FieldValue.serverTimestamp(),
        'qrVerified': checkOutQrVerified,
      },
      'postReflection': postReflection?.toMap(),
      'status': 'complete',
    };
  }

  bool get isComplete => status == 'complete';
  bool get isCheckedIn => status == 'checked-in';
  bool get isIncomplete => status == 'incomplete';
}
