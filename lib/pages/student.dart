import 'package:flutter/material.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final List<String> students = [
    'Aisha Khan',
    'Rahul Sharma',
    'Meera Nair',
  ];

  void _addStudent() {
    setState(() {
      students.add('Student ${students.length + 1}');
    });
  }

  void _deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Students',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addStudent,
                icon: const Icon(Icons.add),
                label: const Text('Add Student'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            final initials = student
                .split(' ')
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part[0].toUpperCase())
                .join();

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
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteStudent(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete student',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
