import 'package:flutter_test/flutter_test.dart';
import 'package:classcheck/models/class_model.dart';

void main() {
  group('ClassModel', () {
    test('fromMap creates correct model', () {
      final map = {
        'name': 'CS101',
        'instructorId': 'instr1',
        'location': {'lat': 13.75, 'lng': 100.50},
        'radius': 150.0,
        'schedule': 'Mon/Wed 10:00 AM',
      };
      final cls = ClassModel.fromMap(map, 'class1');

      expect(cls.id, 'class1');
      expect(cls.name, 'CS101');
      expect(cls.instructorId, 'instr1');
      expect(cls.latitude, 13.75);
      expect(cls.longitude, 100.50);
      expect(cls.radius, 150.0);
      expect(cls.schedule, 'Mon/Wed 10:00 AM');
    });

    test('toMap returns correct structure', () {
      final cls = ClassModel(
        id: 'c1',
        name: 'Math',
        instructorId: 'i1',
        latitude: 40.0,
        longitude: -74.0,
        radius: 200,
        schedule: 'Tue 2PM',
      );
      final map = cls.toMap();

      expect(map['name'], 'Math');
      expect(map['instructorId'], 'i1');
      expect(map['location']['lat'], 40.0);
      expect(map['location']['lng'], -74.0);
      expect(map['radius'], 200);
    });

    test('fromMap handles missing location gracefully', () {
      final cls = ClassModel.fromMap({'name': 'Test'}, 'id1');
      expect(cls.latitude, 0.0);
      expect(cls.longitude, 0.0);
      expect(cls.radius, 100.0);
    });
  });
}
