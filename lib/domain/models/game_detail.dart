import 'package:scorely/domain/models/game.dart';
import 'package:scorely/domain/models/gameplayer.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/domain/models/scorecard.dart';

/// Hält ein komplettes Spiel inklusive aller Teilnehmer und deren Zettel
class GameDetail {
  final Game game;
  final List<PlayerGameSession> sessions;

  GameDetail({required this.game, required this.sessions});

  PlayerGameSession? getPlayerGameSession(int playerId) {
    return sessions.where((s) => s.player.id == playerId).firstOrNull;
  }

  int? getPlayerIndex(int playerId) {
    final index = sessions.indexWhere(
      (session) => session.player.id == playerId,
    );
    return index != -1 ? index : null;
  }
}

/// Verbindet den Spieler, seine Session-Daten und seine Scorecard
class PlayerGameSession {
  final Player player;
  final GamePlayer gamePlayer;
  final Scorecard scorecard;

  PlayerGameSession({
    required this.player,
    required this.gamePlayer,
    required this.scorecard,
  });
}
