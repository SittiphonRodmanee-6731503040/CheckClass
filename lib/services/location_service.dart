import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check and request location permissions
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  // Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Validate if student is within classroom radius
  bool isWithinRadius({
    required double studentLat,
    required double studentLng,
    required double classLat,
    required double classLng,
    required double radiusMeters,
  }) {
    final distance = calculateDistance(
      studentLat,
      studentLng,
      classLat,
      classLng,
    );
    return distance <= radiusMeters;
  }
}
