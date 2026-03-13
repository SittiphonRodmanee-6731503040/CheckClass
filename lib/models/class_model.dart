import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String instructorId;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final String schedule;

  ClassModel({
    required this.id,
    required this.name,
    required this.instructorId,
    required this.latitude,
    required this.longitude,
    this.radius = 100.0,
    this.schedule = '',
  });

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    final location = map['location'] as Map<String, dynamic>? ?? {};
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      instructorId: map['instructorId'] ?? '',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['lng'] as num?)?.toDouble() ?? 0.0,
      radius: (map['radius'] as num?)?.toDouble() ?? 100.0,
      schedule: map['schedule'] ?? '',
    );
  }

  factory ClassModel.fromSnapshot(DocumentSnapshot doc) {
    return ClassModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'instructorId': instructorId,
      'location': {'lat': latitude, 'lng': longitude},
      'radius': radius,
      'schedule': schedule,
    };
  }
}
