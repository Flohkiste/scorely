import 'package:scorely/data/services/game_dao.dart';
import 'package:scorely/data/services/player_dao.dart';
import 'package:scorely/data/services/scorecard_dao.dart';
import 'package:scorely/domain/models/game.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/gameplayer.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/domain/models/scorecard.dart';

class GameRepository {
  final PlayerDao _playerDao;
  final GameDao _gameDao;
  final ScorecardDao _scorecardDao;

  GameRepository({
    required PlayerDao playerDao,
    required GameDao gameDao,
    required ScorecardDao scorecardDao,
  }) : _playerDao = playerDao,
       _gameDao = gameDao,
       _scorecardDao = scorecardDao;

  // ==========================================
  // PLAYERS
  // ==========================================

  /// Lädt alle verfügbaren Spieler
  Future<List<Player>> getAllPlayers() async {
    final maps = await _playerDao.fetchAll();
    return maps.map((map) => Player.fromMap(map)).toList();
  }

  /// Erstellt einen neuen Spieler
  Future<Player> createPlayer(String name) async {
    final newPlayerMap = {'name': name};
    final id = await _playerDao.insert(newPlayerMap);
    return Player(id: id, name: name);
  }

  // ==========================================
  // GAME SETUP & STATE
  // ==========================================

  /// Startet ein neues Spiel mit den gewählten Spieler-IDs
  Future<int> startNewGame(List<int> playerIds) async {
    return await _gameDao.createGameWithPlayers(playerIds);
  }

  /// Lädt den vollständigen Zustand eines Spiels inkl. aller Spieler & Zettel
  Future<GameDetail?> getGameDetail(int gameId) async {
    // 1. Spiel-Eintrag laden
    final activeGameMap = await _gameDao.fetchActiveGame();
    if (activeGameMap == null) return null;

    final game = Game.fromMap(activeGameMap);

    // 2. Alle Mitspieler dieses Spiels laden
    final rawPlayers = await _gameDao.fetchPlayersForGame(gameId);

    final List<PlayerGameSession> sessions = [];

    for (final raw in rawPlayers) {
      final player = Player(id: raw['id'] as int, name: raw['name'] as String);

      final gamePlayer = GamePlayer(
        id: raw['game_player_id'] as int,
        gameId: gameId,
        playerId: player.id!,
        playerOrder: raw['player_order'] as int,
        totalScore: raw['total_score'] as int,
      );

      // Scorecard für diesen Spieler laden
      final scorecardMap = await _scorecardDao.fetchByGamePlayerId(
        gamePlayer.id!,
      );
      final scorecard = scorecardMap != null
          ? Scorecard.fromMap(scorecardMap)
          : Scorecard(gamePlayerId: gamePlayer.id!);

      sessions.add(
        PlayerGameSession(
          player: player,
          gamePlayer: gamePlayer,
          scorecard: scorecard,
        ),
      );
    }

    return GameDetail(game: game, sessions: sessions);
  }

  // ==========================================
  // GAMEPLAY LOGIC
  // ==========================================

  /// Trägt einen Punktestand für einen Spieler ein und wechselt automatisch den Zug
  Future<void> submitScore({
    required int gameId,
    required int gamePlayerId,
    required String columnName,
    required int? scoreValue,
  }) async {
    // 1. Feld eintragen & Punkte/Bonus neu berechnen
    await _scorecardDao.updateCategoryScore(
      gamePlayerId: gamePlayerId,
      columnName: columnName,
      scoreValue: scoreValue,
    );

    // 2. Prüfen, ob das Spiel zu Ende ist (alle Spieler haben alle 13 Felder voll)
    final sessions = (await getGameDetail(gameId))?.sessions ?? [];
    bool allComplete = true;

    for (final session in sessions) {
      final isComplete = await _scorecardDao.isScorecardComplete(
        session.gamePlayer.id!,
      );
      if (!isComplete) {
        allComplete = false;
        break;
      }
    }

    // 3. Entweder Spiel beenden oder nächsten Spieler aufrufen
    if (allComplete) {
      await _gameDao.finishGame(gameId);
    } else {
      await _gameDao.advanceToNextPlayer(gameId);
    }
  }
}
