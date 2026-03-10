import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('users.db');
    return _database!;

  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        age TEXT,
        image TEXT
      )
    ''');

  }

  Future<int> insertUser(User user) async {

    final db = await instance.database;
    return await db.insert('users', user.toMap());

  }

  Future<List<User>> getUsers() async {

    final db = await instance.database;
    final result = await db.query('users');

    return result.map((e) => User.fromMap(e)).toList();

  }

  Future<int> updateUser(User user) async {

    final db = await instance.database;

    return db.update(
      'users',
      user.toMap(),
      where: 'id=?',
      whereArgs: [user.id],
    );

  }

  Future<int> deleteUser(int id) async {

    final db = await instance.database;

    return await db.delete(
      'users',
      where: 'id=?',
      whereArgs: [id],
    );

  }

}