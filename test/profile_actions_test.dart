import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_attendance/database/database.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile and student actions', () {
    late AppDatabase database;

    setUp(() async {
      final uniqueName = 'student_attendance_profile_test_${DateTime.now().microsecondsSinceEpoch}';
      database = AppDatabase(databaseName: uniqueName);
      await database.closeDatabase();
      await database.deleteDatabase();
      await database.init();
    });

    tearDown(() async {
      await database.closeDatabase();
      await database.deleteDatabase();
    });

    test('updates a student name', () async {
      final studentId = await database.insertStudent('Aisha Khan');
      final updatedRows = await database.updateStudentName(studentId, 'Aisha Ali Khan');
      final student = (await database.getStudents()).first;

      expect(updatedRows, 1);
      expect(student.name, 'Aisha Ali Khan');
    });

    test('clears all attendance records', () async {
      final studentId = await database.insertStudent('Rahul Sharma');
      await database.insertAttendance(studentId, '2026-09-18', 'present');
      await database.insertAttendance(studentId, '2026-09-17', 'absent');

      final deletedRows = await database.clearAllAttendance();
      final attendance = await database.getAttendanceForDate('2026-09-18');

      expect(deletedRows, 2);
      expect(attendance, isEmpty);
    });
  });
}
