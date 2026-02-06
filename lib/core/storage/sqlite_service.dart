import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'omnipro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tables for Notes, Shopping List, Recipe Book
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            folder TEXT,
            tags TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE shopping_lists(
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            isCompleted INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE recipes(
            id TEXT PRIMARY KEY,
            title TEXT,
            ingredients TEXT,
            steps TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
  }
}
