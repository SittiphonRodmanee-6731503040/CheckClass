import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import 'check_in_screen.dart';
import 'finish_class_screen.dart';
import 'attendance_history_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassCheck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Attendance History',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen(),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await Helpers.showConfirmDialog(
                context,
                title: 'Sign Out',
                content: 'Are you sure you want to sign out?',
              );
              if (confirm) await _authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              'Welcome, ${_authService.currentUser?.displayName ?? 'Student'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Active class sessions:',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Active sessions list
            Expanded(
              child: StreamBuilder<List<SessionModel>>(
                stream: _firestoreService.getAllOpenSessions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data ?? [];
                  if (sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active class sessions',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sessions will appear here when your instructor starts one.',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return _SessionCard(
                        session: sessions[index],
                        studentId: userId,
                        firestoreService: _firestoreService,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final String studentId;
  final FirestoreService firestoreService;

  const _SessionCard({
    required this.session,
    required this.studentId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel?>(
      future: firestoreService.getClass(session.classId),
      builder: (context, classSnap) {
        final className = classSnap.data?.name ?? 'Loading...';

        return FutureBuilder<AttendanceModel?>(
          future: firestoreService.getStudentAttendance(session.id, studentId),
          builder: (context, attSnap) {
            final attendance = attSnap.data;
            final isCheckedIn = attendance != null;
            final isComplete = attendance?.isComplete ?? false;
            final attendanceId = attendance?.id ?? '';

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.class_,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusChip(
                          isCheckedIn: isCheckedIn,
                          isComplete: isComplete,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Session: ${Helpers.formatDateTime(session.date)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    if (!isCheckedIn)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CheckInScreen(
                                      session: session,
                                      classModel: classSnap.data!,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Check In'),
                        ),
                      )
                    else if (!isComplete)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => FinishClassScreen(
                                      session: session,
                                      attendanceId: attendanceId,
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Finish Class'),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Attendance Complete',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isCheckedIn;
  final bool isComplete;

  const _StatusChip({required this.isCheckedIn, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return const Chip(
        label: Text(
          'Complete',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    if (isCheckedIn) {
      return const Chip(
        label: Text(
          'Checked In',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.orange,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return const Chip(
      label: Text('Not Started', style: TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
