import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: firestoreService.getStudentHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ExpansionTile(
                  leading: Icon(
                    record.isComplete
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: record.isComplete ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    record.checkInTimestamp != null
                        ? Helpers.formatDate(record.checkInTimestamp!)
                        : 'Unknown date',
                  ),
                  subtitle: Text(
                    record.isComplete
                        ? 'Complete'
                        : record.status.toUpperCase(),
                    style: TextStyle(
                      color: record.isComplete ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (record.checkInTimestamp != null) ...[
                            _InfoRow(
                              'Check-in',
                              Helpers.formatDateTime(record.checkInTimestamp!),
                            ),
                          ],
                          if (record.preReflection != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              'Previous Topic',
                              record.preReflection!.previousTopic,
                            ),
                            _InfoRow(
                              'Expected Topic',
                              record.preReflection!.expectedTopic,
                            ),
                            _InfoRow(
                              'Mood',
                              '${Constants.moodEmojis[record.preReflection!.mood]} '
                                  '${Constants.moodLabels[record.preReflection!.mood]}',
                            ),
                          ],
                          if (record.checkOutTimestamp != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              'Check-out',
                              Helpers.formatDateTime(record.checkOutTimestamp!),
                            ),
                          ],
                          if (record.postReflection != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              'Learned',
                              record.postReflection!.learningSummary,
                            ),
                            _InfoRow(
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

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
