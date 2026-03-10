import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/patient.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'doctor_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            phone TEXT,
            condition TEXT,
            notes TEXT,
            last_visit TEXT,
            image_path TEXT,
            doc_path TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return db.insert('patients', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> getPatients() async {
    final db = await database;
    final maps = await db.query('patients', orderBy: 'id DESC');
    return maps.map(Patient.fromMap).toList();
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
