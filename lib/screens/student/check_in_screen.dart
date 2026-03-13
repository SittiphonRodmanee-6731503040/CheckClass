import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/location_status.dart';
import 'qr_scan_screen.dart';
import 'pre_reflection_screen.dart';

class CheckInScreen extends StatefulWidget {
  final SessionModel session;
  final ClassModel classModel;

  const CheckInScreen({
    super.key,
    required this.session,
    required this.classModel,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _locationService = LocationService();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isLoadingLocation = true;
  bool _locationEnabled = false;
  bool _isWithinRange = false;
  double? _distance;
  double? _currentLat;
  double? _currentLng;
  bool _qrVerified = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final hasPermission = await _locationService.checkPermission();
      if (!hasPermission) {
        setState(() {
          _locationEnabled = false;
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await _locationService.getCurrentPosition();
      _currentLat = position.latitude;
      _currentLng = position.longitude;

      final distance = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        widget.classModel.latitude,
        widget.classModel.longitude,
      );

      final isWithin = _locationService.isWithinRadius(
        studentLat: position.latitude,
        studentLng: position.longitude,
        classLat: widget.classModel.latitude,
        classLng: widget.classModel.longitude,
        radiusMeters: widget.classModel.radius,
      );

      setState(() {
        _locationEnabled = true;
        _distance = distance;
        _isWithinRange = isWithin;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationEnabled = false;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );

    if (result != null && result == widget.session.qrCodeData) {
      setState(() {
        _qrVerified = true;
        _currentStep = 2;
      });
    } else if (result != null && mounted) {
      Helpers.showSnackBar(
        context,
        'Invalid QR code. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _proceedToReflection() async {
    final reflectionData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const PreReflectionScreen()),
    );

    if (reflectionData != null && mounted) {
      // Submit check-in
      try {
        final attendance = AttendanceModel(
          id: '',
          sessionId: widget.session.id,
          classId: widget.session.classId,
          studentId: _authService.currentUser!.uid,
          checkInGps: GpsData(lat: _currentLat ?? 0, lng: _currentLng ?? 0),
          checkInTimestamp: DateTime.now(),
          checkInQrVerified: _qrVerified,
          preReflection: PreReflection(
            previousTopic: reflectionData['previousTopic'],
            expectedTopic: reflectionData['expectedTopic'],
            mood: reflectionData['mood'],
          ),
        );

        await _firestoreService.checkIn(attendance);

        if (mounted) {
          Helpers.showSnackBar(context, 'Check-in successful! ✅');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Check-in failed: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          // Step 1: GPS Location
          Step(
            title: const Text('Verify Location'),
            subtitle: const Text('GPS location check'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                if (_isLoadingLocation)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  )
                else
                  LocationStatus(
                    isLocationEnabled: _locationEnabled,
                    isWithinRange: _isWithinRange,
                    distance: _distance,
                    onRetry: _checkLocation,
                  ),
                const SizedBox(height: 16),
                if (_locationEnabled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _currentStep = 1);
                      },
                      child: Text(
                        _isWithinRange
                            ? 'Location Verified — Next'
                            : 'Continue Anyway',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Step 2: QR Code Scan
          Step(
            title: const Text('Scan QR Code'),
            subtitle: const Text('Scan the classroom QR code'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Scan the QR code displayed by your instructor',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _scanQrCode,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Open Scanner'),
                  ),
                ),
              ],
            ),
          ),

          // Step 3: Pre-Class Reflection
          Step(
            title: const Text('Pre-Class Reflection'),
            subtitle: const Text('Share your thoughts before class'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: Column(
              children: [
                const Icon(Icons.edit_note, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Complete a brief reflection before class begins',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _proceedToReflection,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Fill Reflection'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
