import 'package:path/path.dart';
import 'package:scorely/domain/models/game_status.dart';
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
        // 1. PLAYERS Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tablePlayers} (
            ${DatabaseContract.columnPlayerId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnPlayerName} TEXT NOT NULL
          )
        ''');

        // 2. GAMES Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tableGames} (
            ${DatabaseContract.columnGameId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnGameCreatedAt} TEXT NOT NULL,
            ${DatabaseContract.columnGameStatus} TEXT NOT NULL DEFAULT ${GameStatus.running.dbValue},
            ${DatabaseContract.columnGameCurrentPlayerId} INTEGER,
            FOREIGN KEY (${DatabaseContract.columnGameCurrentPlayerId}) 
              REFERENCES ${DatabaseContract.tablePlayers} (${DatabaseContract.columnPlayerId}) 
              ON DELETE SET NULL
          )
        ''');

        // 3. GAME_PLAYERS Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tableGamePlayers} (
            ${DatabaseContract.columnGpId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnGpGameId} INTEGER NOT NULL,
            ${DatabaseContract.columnGpPlayerId} INTEGER NOT NULL,
            ${DatabaseContract.columnGpPlayerOrder} INTEGER NOT NULL,
            ${DatabaseContract.columnGpTotalScore} INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (${DatabaseContract.columnGpGameId}) 
              REFERENCES ${DatabaseContract.tableGames} (${DatabaseContract.columnGameId}) 
              ON DELETE CASCADE,
            FOREIGN KEY (${DatabaseContract.columnGpPlayerId}) 
              REFERENCES ${DatabaseContract.tablePlayers} (${DatabaseContract.columnPlayerId}) 
              ON DELETE CASCADE
          )
        ''');

        // 4. SCORECARDS Table
        await db.execute('''
          CREATE TABLE ${DatabaseContract.tableScorecards} (
            ${DatabaseContract.columnScId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseContract.columnScGamePlayerId} INTEGER UNIQUE NOT NULL,
            ${DatabaseContract.columnScOnes} INTEGER,
            ${DatabaseContract.columnScTwos} INTEGER,
            ${DatabaseContract.columnScThrees} INTEGER,
            ${DatabaseContract.columnScFours} INTEGER,
            ${DatabaseContract.columnScFives} INTEGER,
            ${DatabaseContract.columnScSixes} INTEGER,
            ${DatabaseContract.columnScUpperBonus} INTEGER DEFAULT 0,
            ${DatabaseContract.columnScThreeOfAKind} INTEGER,
            ${DatabaseContract.columnScFourOfAKind} INTEGER,
            ${DatabaseContract.columnScFullHouse} INTEGER,
            ${DatabaseContract.columnScSmallStraight} INTEGER,
            ${DatabaseContract.columnScLargeStraight} INTEGER,
            ${DatabaseContract.columnScKniffel} INTEGER,
            ${DatabaseContract.columnScChance} INTEGER,
            FOREIGN KEY (${DatabaseContract.columnScGamePlayerId}) 
              REFERENCES ${DatabaseContract.tableGamePlayers} (${DatabaseContract.columnGpId}) 
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
