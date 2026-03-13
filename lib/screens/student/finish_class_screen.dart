import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../models/attendance_model.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/location_status.dart';
import 'qr_scan_screen.dart';
import 'post_reflection_screen.dart';

class FinishClassScreen extends StatefulWidget {
  final SessionModel session;
  final String attendanceId;

  const FinishClassScreen({
    super.key,
    required this.session,
    required this.attendanceId,
  });

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _locationService = LocationService();
  final _firestoreService = FirestoreService();

  bool _isLoadingLocation = true;
  bool _locationEnabled = false;
  final bool _isWithinRange = false;
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

      setState(() {
        _locationEnabled = true;
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
      MaterialPageRoute(builder: (_) => const PostReflectionScreen()),
    );

    if (reflectionData != null && mounted) {
      try {
        final attendance = AttendanceModel(
          id: widget.attendanceId,
          sessionId: widget.session.id,
          classId: widget.session.classId,
          studentId: '',
          checkOutGps: GpsData(lat: _currentLat ?? 0, lng: _currentLng ?? 0),
          checkOutTimestamp: DateTime.now(),
          checkOutQrVerified: _qrVerified,
          postReflection: PostReflection(
            learningSummary: reflectionData['learningSummary'],
            feedback: reflectionData['feedback'],
          ),
          status: 'complete',
        );

        await _firestoreService.checkOut(widget.attendanceId, attendance);

        if (mounted) {
          Helpers.showSnackBar(context, 'Class finished! Great job! 🎉');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Error: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
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
                      onPressed: () => setState(() => _currentStep = 1),
                      child: const Text('Next'),
                    ),
                  ),
              ],
            ),
          ),
          Step(
            title: const Text('Scan QR Code'),
            subtitle: const Text('Scan the end-of-class QR code'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Scan the QR code to verify you stayed until the end',
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
          Step(
            title: const Text('Post-Class Reflection'),
            subtitle: const Text('Reflect on what you learned'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: Column(
              children: [
                const Icon(Icons.rate_review, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Share what you learned and your feedback'),
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
