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

  Future<void> _resetAttendance(StudentRecord student) async {
    if (student.id == null) return;
    await _database.deleteAttendanceForStudent(student.id!, _todayDate);
    await _loadAttendance();
  }

  Future<void> _clearTodayAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear today\'s attendance?'),
          content: const Text(
            'This will remove all attendance records for today.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear today'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _database.clearAttendanceForDate(_todayDate);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = constraints.maxWidth < 420;

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
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _clearTodayAttendance,
                          icon: const Icon(Icons.clear_all_rounded, size: 16),
                          label: const Text('Clear Today'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_students.where((student) => _attendanceStatus[student.id] == 'present').length} present • ${_students.where((student) => _attendanceStatus[student.id] == 'absent').length} absent • ${_students.length - _students.where((student) => _attendanceStatus.containsKey(student.id)).length} pending',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _students.isEmpty
                    ? const Center(child: Text('No students available.'))
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final selectedStatus = _attendanceStatus[student.id] ?? '';
                          final statusText = switch (selectedStatus) {
                            'present' => 'Present',
                            'absent' => 'Absent',
                            _ => 'Not marked',
                          };

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
                            child: compactLayout
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Status: $statusText',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: selectedStatus == 'present'
                                                        ? Colors.green
                                                        : selectedStatus == 'absent'
                                                            ? Colors.red
                                                            : Colors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _markAttendance(student.id!, 'present'),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(100, 38),
                                              backgroundColor: selectedStatus == 'present'
                                                  ? Colors.green
                                                  : null,
                                              foregroundColor: selectedStatus == 'present'
                                                  ? Colors.white
                                                  : null,
                                            ),
                                            child: const Text('Present'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => _markAttendance(student.id!, 'absent'),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(100, 38),
                                              side: selectedStatus == 'absent'
                                                  ? const BorderSide(color: Colors.red)
                                                  : null,
                                              foregroundColor: selectedStatus == 'absent'
                                                  ? Colors.red
                                                  : null,
                                            ),
                                            child: const Text('Absent'),
                                          ),
                                          if (selectedStatus.isNotEmpty)
                                            TextButton.icon(
                                              onPressed: () => _resetAttendance(student),
                                              icon: const Icon(Icons.refresh, size: 18),
                                              label: const Text('Reset'),
                                            ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Status: $statusText',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: selectedStatus == 'present'
                                                    ? Colors.green
                                                    : selectedStatus == 'absent'
                                                        ? Colors.red
                                                        : Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
                                          if (selectedStatus.isNotEmpty)
                                            IconButton(
                                              onPressed: () => _resetAttendance(student),
                                              icon: const Icon(Icons.refresh, color: Colors.orange),
                                              tooltip: 'Reset attendance',
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
      },
    );
  }
}
