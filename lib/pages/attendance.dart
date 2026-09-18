import 'package:flutter/material.dart';
import 'package:student_attendance/database/database.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AppDatabase _database = AppDatabase();
  List<StudentRecord> _students = [];
  final Map<int, String> _attendanceStatus = {};

  String get _todayDate => formatDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final students = await _database.getStudents();
    final records = await _database.getAttendanceForDate(_todayDate);

    if (!mounted) return;
    setState(() {
      _students = students;
      _attendanceStatus.clear();
      for (final record in records) {
        _attendanceStatus[record.studentId] = record.status;
      }
    });
  }

  Future<void> _markAttendance(int studentId, String status) async {
    await _database.insertAttendance(studentId, _todayDate, status);
    await _loadAttendance();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _students.isEmpty
                ? const Center(child: Text('No students available.'))
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final selectedStatus = _attendanceStatus[student.id] ?? '';

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                _initials(student.name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                student.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _markAttendance(student.id!, 'present'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    backgroundColor: selectedStatus == 'present'
                                        ? Colors.green
                                        : null,
                                    foregroundColor: selectedStatus == 'present'
                                        ? Colors.white
                                        : null,
                                  ),
                                  child: const Text('Present'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => _markAttendance(student.id!, 'absent'),
                                  style: OutlinedButton.styleFrom(
                                    side: selectedStatus == 'absent'
                                        ? const BorderSide(color: Colors.red)
                                        : null,
                                    foregroundColor: selectedStatus == 'absent'
                                        ? Colors.red
                                        : null,
                                  ),
                                  child: const Text('Absent'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
