import 'package:scorely/business/model/player.dart';
import 'package:scorely/data/services/player_dao.dart';
import 'package:scorely/utils/result.dart';

abstract class IPlayerRepository {
  Future<Result<List<Player>>> getPlayers();
  Future<Result<Player>> getPlayerById(int id);
  Future<Result<Player>> createPlayer(String name);
  Future<Result<void>> deletePlayer(int id);
}

class PlayerRepository implements IPlayerRepository {
  final PlayerDao _playerDao;

  PlayerRepository({required PlayerDao playerDao}) : _playerDao = playerDao;

  // Methoden
  @override
  Future<Result<Player>> createPlayer(String name) async {
    try {
      final playerToInsert = Player(name: name);
      final generatedId = await _playerDao.insert(playerToInsert.toMap());

      final createdPlayer = playerToInsert.copyWith(id: generatedId);
      return Result.ok(createdPlayer);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deletePlayer(int id) async {
    try {
      final rowsAffected = await _playerDao.delete(id);
      if (rowsAffected > 0) {
        return Result.ok(null);
      } else {
        throw Exception('Player with id $id not found');
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Player>> getPlayerById(int id) {
    // TODO: implement getPlayerById
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Player>>> getPlayers() async {
    try {
      final rawMaps = await _playerDao.fetchAll();
      final players = rawMaps.map((map) => Player.fromMap(map)).toList();
      return Result.ok(players);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
