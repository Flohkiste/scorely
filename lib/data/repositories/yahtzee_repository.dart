import 'package:scorely/data/daos/yahtzee_dao.dart';
import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/domain/models/game.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/game_status.dart';
import 'package:scorely/domain/models/gameplayer.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/domain/models/scorecard.dart';
import 'package:scorely/utils/result.dart';

abstract class IYahtzeeRepository {
  Future<Result<GameDetail?>> loadRunningGame();
  Future<Result<GameDetail>> loadGameById(int gameId);
  Future<Result<int>> createGame(List<int> playerIds);
  Future<Result<void>> updateScoreField(
    int scorecardId,
    String fieldName,
    int score,
  );
  Future<Result<void>> changeActivePlayer(int gameId, int activePlayerId);
  Future<Result<void>> endGame(int gameId);
  Future<Result<List<GameDetail>>> loadGameHistory();
}

class YahtzeeRepository implements IYahtzeeRepository {
  final YahtzeeDao _yahtzeeDao;

  YahtzeeRepository({required YahtzeeDao yahtzeeDao})
    : _yahtzeeDao = yahtzeeDao;

  // Changes active player
  @override
  Future<Result<void>> changeActivePlayer(
    int gameId,
    int activePlayerId,
  ) async {
    try {
      await _yahtzeeDao.changeActivePlayer(gameId, activePlayerId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // creates new game and returns the game id
  @override
  Future<Result<int>> createGame(List<int> playerIds) async {
    try {
      final gameId = await _yahtzeeDao.createGameWithPlayers(playerIds);
      return Result.ok(gameId);
    } on Object catch (e) {
      if (e is Exception) {
        return Result.error(e);
      }
      return Result.error(Exception(e.toString()));
    }
  }

  // sets status of the game to completed
  @override
  Future<Result<void>> endGame(int gameId) async {
    try {
      await _yahtzeeDao.updateGameStatus(gameId, GameStatus.completed);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<GameDetail>> loadGameById(int gameId) async {
    try {
      final rows = await _yahtzeeDao.fetchGameById(gameId);

      if (rows.isEmpty) {
        return Result.error(Exception("Game with id $gameId doesn't exist"));
      }

      final gameDetail = _mapRowsToGameDetail(rows);
      return Result.ok(gameDetail);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<GameDetail>>> loadGameHistory() {
    // TODO: implement loadGameHistory
    throw UnimplementedError();
  }

  // load running game returns null if no game is currently running
  @override
  Future<Result<GameDetail?>> loadRunningGame() async {
    try {
      final rows = await _yahtzeeDao.fetchGameByRunning();

      if (rows == null || rows.isEmpty) {
        return Result.ok(null);
      }

      final gameDetail = _mapRowsToGameDetail(rows);

      return Result.ok(gameDetail);
    } on Object catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  GameDetail _mapRowsToGameDetail(List<Map<String, dynamic>> rows) {
    final firstRow = rows.first;
    final game = Game(
      id: firstRow['game_id'] as int,
      createdAt: DateTime.parse(
        firstRow[DatabaseContract.columnGameCreatedAt] as String,
      ),
      status: GameStatus.fromDbValue(
        firstRow[DatabaseContract.columnGameStatus] as String,
      ),
      currentPlayerId:
          firstRow[DatabaseContract.columnGameCurrentPlayerId] as int?,
    );

    // 2. Alle Spiel-Sessions (Spieler + GamePlayer-Zuordnung + Scorecard) zusammensetzen
    final sessions = rows.map((row) {
      final player = Player(
        id: row['player_id'] as int,
        name: row[DatabaseContract.columnPlayerName] as String,
      );

      final gamePlayer = GamePlayer(
        id: row['game_player_id'] as int,
        gameId: game.id!,
        playerId: player.id!,
        playerOrder: row[DatabaseContract.columnGpPlayerOrder] as int,
        totalScore: row[DatabaseContract.columnGpTotalScore] as int? ?? 0,
      );

      // Map für die Scorecard vorbereiten (mit der gemappten scorecard_id)
      final scorecardMap = Map<String, dynamic>.from(row);
      scorecardMap[DatabaseContract.columnScId] = row['scorecard_id'];

      final scorecard = Scorecard.fromMap(scorecardMap);

      return PlayerGameSession(
        player: player,
        gamePlayer: gamePlayer,
        scorecard: scorecard,
      );
    }).toList();

    return GameDetail(game: game, sessions: sessions);
  }

  @override
  Future<Result<void>> updateScoreField(
    int scorecardId,
    String fieldName,
    int? score,
  ) async {
    try {
      await _yahtzeeDao.updateScoreField(scorecardId, fieldName, score);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
