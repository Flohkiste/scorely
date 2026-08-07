import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/data/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PlayerDao {
  final DatabaseService _dbService;

  PlayerDao({required DatabaseService dbService}) : _dbService = dbService;

  /// Alle Spieler alphabetisch sortiert abrufen
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await _dbService.database;
    return await db.query(
      DatabaseContract.tablePlayers,
      columns: [
        DatabaseContract.columnPlayerId,
        DatabaseContract.columnPlayerName,
      ],
      orderBy: '${DatabaseContract.columnPlayerName} ASC',
    );
  }

  /// Einzelnen Spieler anhand seiner ID abrufen
  Future<Map<String, dynamic>?> fetchById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      DatabaseContract.tablePlayers,
      where: '${DatabaseContract.columnPlayerId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Neuen Spieler einfügen
  Future<int> insert(Map<String, dynamic> playerMap) async {
    final db = await _dbService.database;
    return await db.insert(
      DatabaseContract.tablePlayers,
      playerMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // Falls ID schon existiert
    );
  }

  /// Spielername aktualisieren
  Future<int> update(Map<String, dynamic> playerMap) async {
    final db = await _dbService.database;
    final id = playerMap[DatabaseContract.columnPlayerId];
    return await db.update(
      DatabaseContract.tablePlayers,
      playerMap,
      where: '${DatabaseContract.columnPlayerId} = ?',
      whereArgs: [id],
    );
  }

  /// Spieler löschen
  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      DatabaseContract.tablePlayers,
      where: '${DatabaseContract.columnPlayerId} = ?',
      whereArgs: [id],
    );
  }
}
