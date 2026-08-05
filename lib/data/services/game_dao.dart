import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/data/services/database_service.dart';

class GameDao {
  final DatabaseService _dbService;

  GameDao({required DatabaseService dbService}) : _dbService = dbService;

  /// Startet ein neues Spiel mit einer Liste von Spieler-IDs (in Sitzreihenfolge).
  /// Erstellt atomar den Spieleintrag, die Verknüpfungen in `game_players`
  /// und die zugehörigen leeren `scorecards`.
  Future<int> createGameWithPlayers(List<int> playerIds) async {
    if (playerIds.isEmpty) {
      throw ArgumentError('Ein Spiel benötigt mindestens einen Spieler.');
    }

    final db = await _dbService.database;

    return await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final firstPlayerId = playerIds.first;

      // 1. Spiel-Eintrag in `games` anlegen (Erster Spieler ist startberechtigt)
      final gameId = await txn.insert(DatabaseContract.tableGames, {
        DatabaseContract.columnGameCreatedAt: now,
        DatabaseContract.columnGameStatus: 'in_progress',
        DatabaseContract.columnGameCurrentPlayerId: firstPlayerId,
      });

      // 2. Für jeden Spieler die Verknüpfung und die Scorecard anlegen
      for (int i = 0; i < playerIds.length; i++) {
        final playerId = playerIds[i];
        final playerOrder = i + 1;

        // Eintrag in `game_players`
        final gamePlayerId = await txn
            .insert(DatabaseContract.tableGamePlayers, {
              DatabaseContract.columnGpGameId: gameId,
              DatabaseContract.columnGpPlayerId: playerId,
              DatabaseContract.columnGpPlayerOrder: playerOrder,
              DatabaseContract.columnGpTotalScore: 0,
            });

        // Zugehörige leere `scorecard` anlegen
        await txn.insert(DatabaseContract.tableScorecards, {
          DatabaseContract.columnScGamePlayerId: gamePlayerId,
          DatabaseContract.columnScUpperBonus: 0,
        });
      }

      return gameId;
    });
  }

  /// Ruft das aktuell aktive Spiel ab (falls eines läuft)
  Future<Map<String, dynamic>?> fetchActiveGame() async {
    final db = await _dbService.database;
    final results = await db.query(
      DatabaseContract.tableGames,
      where: '${DatabaseContract.columnGameStatus} = ?',
      whereArgs: ['in_progress'],
      orderBy: '${DatabaseContract.columnGameCreatedAt} DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Lädt ein Spiel inklusive aller Mitspieler (sortiert nach Reihenfolge `player_order`)
  Future<List<Map<String, dynamic>>> fetchPlayersForGame(int gameId) async {
    final db = await _dbService.database;

    return await db.rawQuery(
      '''
      SELECT 
        gp.${DatabaseContract.columnGpId} AS game_player_id,
        gp.${DatabaseContract.columnGpPlayerOrder},
        gp.${DatabaseContract.columnGpTotalScore},
        p.${DatabaseContract.columnPlayerId},
        p.${DatabaseContract.columnPlayerName}
      FROM ${DatabaseContract.tableGamePlayers} gp
      INNER JOIN ${DatabaseContract.tablePlayers} p 
        ON gp.${DatabaseContract.columnGpPlayerId} = p.${DatabaseContract.columnPlayerId}
      WHERE gp.${DatabaseContract.columnGpGameId} = ?
      ORDER BY gp.${DatabaseContract.columnGpPlayerOrder} ASC
    ''',
      [gameId],
    );
  }

  /// Welchselt zum nächsten Spieler im Spiel (Reihenfolge 1 -> 2 -> 3 -> 1)
  Future<void> advanceToNextPlayer(int gameId) async {
    final db = await _dbService.database;

    // 1. Alle Spieler des Spiels nach ihrer Reihenfolge abrufen
    final players = await fetchPlayersForGame(gameId);
    if (players.isEmpty) return;

    // 2. Aktuelles Spiel laden, um den aktuellen Spieler zu kennen
    final gameResult = await db.query(
      DatabaseContract.tableGames,
      columns: [DatabaseContract.columnGameCurrentPlayerId],
      where: '${DatabaseContract.columnGameId} = ?',
      whereArgs: [gameId],
      limit: 1,
    );

    if (gameResult.isEmpty) return;
    final currentPlayerId =
        gameResult.first[DatabaseContract.columnGameCurrentPlayerId] as int?;

    // 3. Index des aktuellen Spielers ermitteln und den nächsten bestimmen
    int currentIndex = players.indexWhere(
      (p) => p[DatabaseContract.columnPlayerId] == currentPlayerId,
    );

    int nextIndex = (currentIndex + 1) % players.length;
    int nextPlayerId =
        players[nextIndex][DatabaseContract.columnPlayerId] as int;

    // 4. `current_player_id` im Spiel aktualisieren
    await db.update(
      DatabaseContract.tableGames,
      {DatabaseContract.columnGameCurrentPlayerId: nextPlayerId},
      where: '${DatabaseContract.columnGameId} = ?',
      whereArgs: [gameId],
    );
  }

  /// Beendet ein Spiel und schließt es ab
  Future<void> finishGame(int gameId) async {
    final db = await _dbService.database;
    await db.update(
      DatabaseContract.tableGames,
      {
        DatabaseContract.columnGameStatus: 'completed',
        DatabaseContract.columnGameCurrentPlayerId: null,
      },
      where: '${DatabaseContract.columnGameId} = ?',
      whereArgs: [gameId],
    );
  }
}
