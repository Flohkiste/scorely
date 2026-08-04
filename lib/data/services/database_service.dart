import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_contract.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseContract.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseContract.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // 1. Players Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tablePlayers} (
            ${DatabaseContract.columnPlayerId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnPlayerName} TEXT NOT NULL
          )
        ''');

        // 2. Games Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tableGames} (
            ${DatabaseContract.columnGameId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnCreatedAt} TEXT NOT NULL
          )
        ''');

        // 3. Game-Players Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tableGamePlayers} (
            ${DatabaseContract.columnGpGameId} INTEGER NOT NULL,
            ${DatabaseContract.columnGpPlayerId} INTEGER NOT NULL,
            ${DatabaseContract.columnGpScore} INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (${DatabaseContract.columnGpGameId}, ${DatabaseContract.columnGpPlayerId}),
            FOREIGN KEY (${DatabaseContract.columnGpGameId}) REFERENCES ${DatabaseContract.tableGames} (${DatabaseContract.columnGameId}) ON DELETE CASCADE,
            FOREIGN KEY (${DatabaseContract.columnGpPlayerId}) REFERENCES ${DatabaseContract.tablePlayers} (${DatabaseContract.columnPlayerId}) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
