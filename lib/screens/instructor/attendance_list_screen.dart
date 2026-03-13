import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class AttendanceListScreen extends StatelessWidget {
  final String sessionId;

  const AttendanceListScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: firestoreService.getSessionAttendance(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text('No attendance records for this session.'),
            );
          }

          // Summary stats
          final total = records.length;
          final complete = records.where((r) => r.isComplete).length;
          final checkedIn = records.where((r) => r.isCheckedIn).length;

          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Total',
                      value: '$total',
                      color: Colors.blue,
                    ),
                    _StatItem(
                      label: 'Complete',
                      value: '$complete',
                      color: Colors.green,
                    ),
                    _StatItem(
                      label: 'In Progress',
                      value: '$checkedIn',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return FutureBuilder<UserModel?>(
                      future: authService.getUserProfile(record.studentId),
                      builder: (context, userSnap) {
                        final studentName = userSnap.data?.name ?? 'Loading...';

                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  record.isComplete
                                      ? Colors.green
                                      : Colors.orange,
                              child: Icon(
                                record.isComplete
                                    ? Icons.check
                                    : Icons.hourglass_bottom,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(studentName),
                            subtitle: Text(
                              record.isComplete ? 'Complete' : 'Checked in',
                              style: TextStyle(
                                color:
                                    record.isComplete
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (record.checkInTimestamp != null)
                                      _DetailRow(
                                        'Check-in',
                                        Helpers.formatDateTime(
                                          record.checkInTimestamp!,
                                        ),
                                      ),
                                    if (record.checkInGps != null)
                                      _DetailRow(
                                        'GPS',
                                        '${record.checkInGps!.lat.toStringAsFixed(4)}, ${record.checkInGps!.lng.toStringAsFixed(4)}',
                                      ),
                                    _DetailRow(
                                      'QR Verified',
                                      record.checkInQrVerified
                                          ? '✅ Yes'
                                          : '❌ No',
                                    ),
                                    if (record.preReflection != null) ...[
                                      const Divider(),
                                      const Text(
                                        'Pre-Class Reflection',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _DetailRow(
                                        'Previous Topic',
                                        record.preReflection!.previousTopic,
                                      ),
                                      _DetailRow(
                                        'Expected Topic',
                                        record.preReflection!.expectedTopic,
                                      ),
                                      _DetailRow(
                                        'Mood',
                                        '${Constants.moodEmojis[record.preReflection!.mood]} ${Constants.moodLabels[record.preReflection!.mood]}',
                                      ),
                                    ],
                                    if (record.checkOutTimestamp != null) ...[
                                      const Divider(),
                                      _DetailRow(
                                        'Check-out',
                                        Helpers.formatDateTime(
                                          record.checkOutTimestamp!,
                                        ),
                                      ),
                                    ],
                                    if (record.postReflection != null) ...[
                                      const Divider(),
                                      const Text(
                                        'Post-Class Reflection',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _DetailRow(
                                        'Learned',
                                        record.postReflection!.learningSummary,
                                      ),
                                      _DetailRow(
                                        'Feedback',
                                        record.postReflection!.feedback,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
