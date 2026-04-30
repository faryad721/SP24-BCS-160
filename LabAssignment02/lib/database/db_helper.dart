import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guess INTEGER,
        result TEXT,
        difficulty TEXT,
        attempts INTEGER,
        time TEXT
      )
    ''');
  }

  // ➕ Insert
  Future<void> insertGame(GameModel game) async {
    final db = await database;
    await db.insert('games', game.toMap());
  }

  // 📜 Get All
  Future<List<GameModel>> getAllGames() async {
    final db = await database;
    final result = await db.query('games', orderBy: 'id DESC');

    return result.map((e) => GameModel.fromMap(e)).toList();
  }

  // 🗑 Delete All
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('games');
  }
}