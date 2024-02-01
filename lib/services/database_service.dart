import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String databaseName = 'expenso.db';
  static const int databaseVersion = 1;
  static Database? _database;

  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<bool> initializeDatabase() async {
    if (_database != null) {
      return true; // Database already exists
    }

    _database = await _initDatabase();
    return _database != null;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);
    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _createDatabase,
      singleInstance: true,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        beneficiary TEXT,
        amount REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        content TEXT,
        sender TEXT,
        receivedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        beneficiary TEXT,
        amount REAL,
        date TEXT
      )
    ''');
  }
}