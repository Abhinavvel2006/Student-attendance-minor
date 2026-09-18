import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      {'name': 'Aisha Khan', 'initials': 'AK'},
      {'name': 'Rahul Sharma', 'initials': 'RS'},
      {'name': 'Meera Nair', 'initials': 'MN'},
    ];

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
          ...students.map((student) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      student['initials']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student['name']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Present'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Absent'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
