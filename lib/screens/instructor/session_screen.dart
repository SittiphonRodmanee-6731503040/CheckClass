import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../models/session_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/qr_display.dart';
import 'attendance_list_screen.dart';

class SessionScreen extends StatefulWidget {
  final ClassModel classModel;

  const SessionScreen({super.key, required this.classModel});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _startSession() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.createSession(widget.classModel.id);
      if (mounted) {
        Helpers.showSnackBar(context, 'Session started!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _endSession(String sessionId) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'End Session',
      content:
          'Are you sure you want to end this session? Students will no longer be able to check in.',
    );
    if (!confirm) return;

    try {
      await _firestoreService.closeSession(sessionId);
      if (mounted) {
        Helpers.showSnackBar(context, 'Session ended.');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.classModel.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.classModel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.classModel.schedule.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.classModel.schedule,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Session
            const Text(
              'Current Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<SessionModel?>(
              stream: _firestoreService.getActiveSession(widget.classModel.id),
              builder: (context, snapshot) {
                final activeSession = snapshot.data;

                if (activeSession == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text('No active session'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _startSession,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Session'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 10, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                'Session Active',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Started: ${Helpers.formatDateTime(activeSession.date)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // QR Code display
                        QrDisplay(
                          data: activeSession.qrCodeData,
                          label: 'Students scan this QR code to check in',
                        ),
                        const SizedBox(height: 20),

                        // View attendance
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AttendanceListScreen(
                                        sessionId: activeSession.id,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('View Attendance'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _endSession(activeSession.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.stop),
                            label: const Text('End Session'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Past Sessions
            const Text(
              'Past Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<SessionModel>>(
              stream: _firestoreService.getClassSessions(widget.classModel.id),
              builder: (context, snapshot) {
                final sessions =
                    (snapshot.data ?? []).where((s) => !s.isOpen).toList();

                if (sessions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No past sessions yet.'),
                    ),
                  );
                }

                return Column(
                  children:
                      sessions.map((session) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(Helpers.formatDateTime(session.date)),
                            subtitle: const Text('Session closed'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AttendanceListScreen(
                                        sessionId: session.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
