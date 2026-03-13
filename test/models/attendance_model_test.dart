import 'package:flutter_test/flutter_test.dart';
import 'package:classcheck/models/attendance_model.dart';

void main() {
  group('GpsData', () {
    test('fromMap and toMap roundtrip', () {
      final gps = GpsData(lat: 13.75, lng: 100.50);
      final map = gps.toMap();
      final restored = GpsData.fromMap(map);

      expect(restored.lat, 13.75);
      expect(restored.lng, 100.50);
    });
  });

  group('PreReflection', () {
    test('fromMap and toMap roundtrip', () {
      final ref = PreReflection(
        previousTopic: 'Arrays',
        expectedTopic: 'Linked Lists',
        mood: 4,
      );
      final map = ref.toMap();
      final restored = PreReflection.fromMap(map);

      expect(restored.previousTopic, 'Arrays');
      expect(restored.expectedTopic, 'Linked Lists');
      expect(restored.mood, 4);
    });
  });

  group('PostReflection', () {
    test('fromMap and toMap roundtrip', () {
      final ref = PostReflection(
        learningSummary: 'Learned about trees',
        feedback: 'Great class',
      );
      final map = ref.toMap();
      final restored = PostReflection.fromMap(map);

      expect(restored.learningSummary, 'Learned about trees');
      expect(restored.feedback, 'Great class');
    });
  });

  group('AttendanceModel', () {
    test('status helpers work correctly', () {
      final checkedIn = AttendanceModel(
        id: '1',
        sessionId: 's1',
        classId: 'c1',
        studentId: 'u1',
        status: 'checked-in',
      );
      expect(checkedIn.isCheckedIn, true);
      expect(checkedIn.isComplete, false);
      expect(checkedIn.isIncomplete, false);

      final complete = AttendanceModel(
        id: '2',
        sessionId: 's1',
        classId: 'c1',
        studentId: 'u1',
        status: 'complete',
      );
      expect(complete.isComplete, true);

      final incomplete = AttendanceModel(
        id: '3',
        sessionId: 's1',
        classId: 'c1',
        studentId: 'u1',
        status: 'incomplete',
      );
      expect(incomplete.isIncomplete, true);
    });

    test('toCheckInMap includes correct fields', () {
      final attendance = AttendanceModel(
        id: '',
        sessionId: 's1',
        classId: 'c1',
        studentId: 'u1',
        checkInGps: GpsData(lat: 13.75, lng: 100.50),
        checkInTimestamp: DateTime(2026, 3, 13, 10, 0),
        checkInQrVerified: true,
        preReflection: PreReflection(
          previousTopic: 'Topic A',
          expectedTopic: 'Topic B',
          mood: 5,
        ),
      );

      final map = attendance.toCheckInMap();
      expect(map['sessionId'], 's1');
      expect(map['classId'], 'c1');
      expect(map['studentId'], 'u1');
      expect(map['status'], 'checked-in');
      expect(map['checkIn']['qrVerified'], true);
      expect(map['preReflection']['mood'], 5);
    });

    test('toCheckOutMap includes correct fields', () {
      final attendance = AttendanceModel(
        id: 'a1',
        sessionId: 's1',
        classId: 'c1',
        studentId: 'u1',
        checkOutGps: GpsData(lat: 13.76, lng: 100.51),
        checkOutTimestamp: DateTime(2026, 3, 13, 12, 0),
        checkOutQrVerified: true,
        postReflection: PostReflection(
          learningSummary: 'Learned X',
          feedback: 'Good',
        ),
        status: 'complete',
      );

      final map = attendance.toCheckOutMap();
      expect(map['status'], 'complete');
      expect(map['checkOut']['qrVerified'], true);
      expect(map['postReflection']['learningSummary'], 'Learned X');
    });
  });
}
