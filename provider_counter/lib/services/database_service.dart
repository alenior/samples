import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medication.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''CREATE TABLE medications(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            dosage TEXT NOT NULL,
            instructions TEXT,
            reminderTimes TEXT NOT NULL
          )''',
        );
      },
    );
  }

  Future<List<Medication>> getMedications() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('medications');

      return maps.map((map) => Medication.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get medications: ${e.toString()}');
    }
  }

  Future<void> insertMedication(Medication medication) async {
    try {
      final db = await database;
      await db.insert(
        'medications',
        medication.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert medication: ${e.toString()}');
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      final db = await database;
      await db.delete(
        'medications',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete medication: ${e.toString()}');
    }
  }
}