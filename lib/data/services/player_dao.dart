import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/data/services/database_service.dart';

class PlayerDao {
  final DatabaseService _dbService;

  PlayerDao({required DatabaseService dbService}) : _dbService = dbService;

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

  Future<int> insert(Map<String, dynamic> playerMap) async {
    final db = await _dbService.database;
    return await db.insert(DatabaseContract.tablePlayers, playerMap);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      DatabaseContract.tablePlayers,
      where: '${DatabaseContract.columnPlayerId} = ?',
      whereArgs: [id],
    );
  }
}
