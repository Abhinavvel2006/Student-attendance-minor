import 'package:sqflite/sqflite.dart';

String formatDate(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class StudentRecord {
  final int? id;
  final String name;

  StudentRecord({this.id, required this.name});

  factory StudentRecord.fromMap(Map<String, dynamic> map) {
    return StudentRecord(id: map['id'] as int?, name: map['name'] as String);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}

class AttendanceRecord {
  final int? id;
  final int studentId;
  final String date;
  final String status;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      date: map['date'] as String,
      status: (map['status'] as String).toLowerCase(),
    );
  }
}

class StudentPerformance {
  final int studentId;
  final String name;
  final int presentCount;
  final int totalCount;

  StudentPerformance({
    required this.studentId,
    required this.name,
    required this.presentCount,
    required this.totalCount,
  });

  double get attendancePercent {
    if (totalCount == 0) {
      return 0;
    }
    return (presentCount / totalCount) * 100;
  }

  String get percentText => '${attendancePercent.toStringAsFixed(0)}%';
}

class SqfliteDatabaseService {
  static Future<int> countRows(String tableName) async {
    final db = await AppDatabase().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase({String? databaseName}) {
    if (databaseName != null) {
      return AppDatabase._internal(databaseName: databaseName);
    }
    return _instance;
  }

  AppDatabase._internal({this.databaseName = 'student_attendance'});

  final String databaseName;
  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$databaseName.db';

    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'present',
        UNIQUE(student_id, date),
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
  }

  Future<void> deleteDatabase() async {
    await closeDatabase();
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$databaseName.db';
    await databaseFactory.deleteDatabase(path);
  }

  Future<int> insertStudent(String name) async {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError('Student name cannot be empty');
    }

    final db = await database;
    final existing = await db.query(
      'students',
      where: 'LOWER(name) = ?',
      whereArgs: [cleanedName.toLowerCase()],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw ArgumentError('Student name must be unique');
    }

    return db.insert('students', {
      'name': cleanedName,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<StudentRecord>> getStudents() async {
    final db = await database;
    final maps = await db.query('students', orderBy: 'id ASC');

    return maps.map(StudentRecord.fromMap).toList();
  }

  Future<int> deleteStudent(int studentId) async {
    final db = await database;
    return db.delete('students', where: 'id = ?', whereArgs: [studentId]);
  }

  Future<int> updateStudentName(int studentId, String newName) async {
    final cleanedName = newName.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError('Student name cannot be empty');
    }

    final db = await database;
    final existing = await db.query(
      'students',
      where: 'id != ? AND LOWER(name) = ?',
      whereArgs: [studentId, cleanedName.toLowerCase()],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw ArgumentError('Student name must be unique');
    }

    return db.update(
      'students',
      {'name': cleanedName},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> insertAttendance(
    int studentId,
    String date,
    String status,
  ) async {
    final db = await database;
    final normalizedStatus = status.trim().toLowerCase();

    return db.insert('attendance', {
      'student_id': studentId,
      'date': date,
      'status': normalizedStatus,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );

    return maps.map(AttendanceRecord.fromMap).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceForStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );

    return maps.map(AttendanceRecord.fromMap).toList();
  }

  Future<int> clearAttendanceForDate(String date) async {
    final db = await database;
    return db.delete('attendance', where: 'date = ?', whereArgs: [date]);
  }

  Future<int> clearAllAttendance() async {
    final db = await database;
    return db.delete('attendance');
  }

  Future<int> deleteAttendanceForStudent(int studentId, String date) async {
    final db = await database;
    return db.delete(
      'attendance',
      where: 'student_id = ? AND date = ?',
      whereArgs: [studentId, date],
    );
  }

  Future<List<StudentPerformance>> getStudentPerformance() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        s.id AS student_id,
        s.name,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_count,
        COUNT(a.id) AS total_count
      FROM students s
      LEFT JOIN attendance a ON a.student_id = s.id
      GROUP BY s.id, s.name
      ORDER BY s.id ASC
    ''');

    return rows.map((row) {
      return StudentPerformance(
        studentId: (row['student_id'] as int?) ?? 0,
        name: row['name'] as String,
        presentCount: (row['present_count'] as int?) ?? 0,
        totalCount: (row['total_count'] as int?) ?? 0,
      );
    }).toList();
  }
}
