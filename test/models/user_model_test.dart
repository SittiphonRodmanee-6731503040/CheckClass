import 'package:flutter_test/flutter_test.dart';
import 'package:classcheck/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates correct model', () {
      final map = {
        'name': 'John Doe',
        'email': 'john@test.com',
        'role': 'student',
      };
      final user = UserModel.fromMap(map, 'uid123');

      expect(user.uid, 'uid123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@test.com');
      expect(user.role, 'student');
    });

    test('toMap returns correct map', () {
      final user = UserModel(
        uid: 'uid123',
        name: 'Jane',
        email: 'jane@test.com',
        role: 'instructor',
      );
      final map = user.toMap();

      expect(map['name'], 'Jane');
      expect(map['email'], 'jane@test.com');
      expect(map['role'], 'instructor');
      expect(map.containsKey('uid'), false);
    });

    test('isInstructor returns true for instructor role', () {
      final user = UserModel(
        uid: '1',
        name: 'Prof',
        email: 'p@t.com',
        role: 'instructor',
      );
      expect(user.isInstructor, true);
      expect(user.isStudent, false);
    });

    test('isStudent returns true for student role', () {
      final user = UserModel(
        uid: '1',
        name: 'Stu',
        email: 's@t.com',
        role: 'student',
      );
      expect(user.isStudent, true);
      expect(user.isInstructor, false);
    });

    test('fromMap handles missing fields with defaults', () {
      final user = UserModel.fromMap({}, 'uid');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.role, 'student');
    });
  });
}
