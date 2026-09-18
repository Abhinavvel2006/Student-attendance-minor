import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_attendance/database/database.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SQLite database', () {
    late AppDatabase database;

    setUp(() async {
      final uniqueName = 'student_attendance_test_${DateTime.now().microsecondsSinceEpoch}';
      database = AppDatabase(databaseName: uniqueName);
      await database.closeDatabase();
      await database.deleteDatabase();
      await database.init();
    });

    tearDown(() async {
      await database.closeDatabase();
      await database.deleteDatabase();
    });

    test('creates student and attendance tables', () async {
      final studentCount = await SqfliteDatabaseService.countRows('students');
      final attendanceCount = await SqfliteDatabaseService.countRows('attendance');

      expect(studentCount, 0);
      expect(attendanceCount, 0);
    });

    test('inserts and reads student records', () async {
      final id = await database.insertStudent('Aisha Khan');
      final students = await database.getStudents();

      expect(id, greaterThan(0));
      expect(students.length, 1);
      expect(students.first.name, 'Aisha Khan');
    });

    test('inserts and reads attendance records for a student', () async {
      final studentId = await database.insertStudent('Rahul Sharma');
      await database.insertAttendance(studentId, '2026-09-18', 'present');

      final attendance = await database.getAttendanceForDate('2026-09-18');

      expect(attendance.length, 1);
      expect(attendance.first.studentId, studentId);
      expect(attendance.first.status, 'present');
    });
  });
}
