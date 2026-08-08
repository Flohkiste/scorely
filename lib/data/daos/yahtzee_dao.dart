import 'package:flutter/material.dart';
import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/data/services/database_service.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/game_status.dart';

class YahtzeeDao {
  final DatabaseService _dbService;

  YahtzeeDao({required DatabaseService dbService}) : _dbService = dbService;

  // Creates a new game with player ids
  Future<int> createGameWithPlayers(List<int> playerIds) async {
    if (playerIds.length < 2) {
      throw ArgumentError(
        'At least two players have to be selected to create a game',
      );
    }

    final db = await _dbService.database;

    final gameId = await db.transaction((txn) async {
      final gameId = await txn.insert(DatabaseContract.tableGames, {
        DatabaseContract.columnGameCreatedAt: DateTime.now().toIso8601String(),
        DatabaseContract.columnGameStatus: GameStatus.running.dbValue,
        DatabaseContract.columnGameCurrentPlayerId: playerIds.first,
      });

      for (int i = 0; i < playerIds.length; i++) {
        final player = playerIds[i];
        final order = i;

        final gamePlayerId = await txn
            .insert(DatabaseContract.tableGamePlayers, {
              DatabaseContract.columnGpGameId: gameId,
              DatabaseContract.columnGpPlayerId: player,
              DatabaseContract.columnGpPlayerOrder: order,
              DatabaseContract.columnGpTotalScore: 0,
            });

        await txn.insert(DatabaseContract.tableScorecards, {
          DatabaseContract.columnScGamePlayerId: gamePlayerId,
        });
      }

      return gameId;
    });

    return gameId;
  }

  // Returns Game from Id
  Future<List<Map<String, dynamic>>> fetchGameById(int gameId) async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      '''
      SELECT g.${DatabaseContract.columnGameId} AS game_id, 
      g.${DatabaseContract.columnGameCreatedAt}, 
      g.${DatabaseContract.columnGameStatus}, 
      g.${DatabaseContract.columnGameCurrentPlayerId}, 
      gp.${DatabaseContract.columnGpId} AS game_player_id, 
      gp.${DatabaseContract.columnGpPlayerOrder}, 
      gp.${DatabaseContract.columnGpTotalScore}, 
      p.${DatabaseContract.columnPlayerId} AS player_id, 
      p.${DatabaseContract.columnPlayerName}, 
      sc.${DatabaseContract.columnScId} AS scorecard_id,
      sc.${DatabaseContract.columnScOnes},
      sc.${DatabaseContract.columnScTwos},
      sc.${DatabaseContract.columnScThrees},
      sc.${DatabaseContract.columnScFours},
      sc.${DatabaseContract.columnScFives},
      sc.${DatabaseContract.columnScSixes},
      sc.${DatabaseContract.columnScUpperBonus},
      sc.${DatabaseContract.columnScThreeOfAKind},
      sc.${DatabaseContract.columnScFourOfAKind},
      sc.${DatabaseContract.columnScFullHouse},
      sc.${DatabaseContract.columnScSmallStraight},
      sc.${DatabaseContract.columnScLargeStraight},
      sc.${DatabaseContract.columnScYahtzee},
      sc.${DatabaseContract.columnScChance}      
      FROM ${DatabaseContract.tableGames} g, ${DatabaseContract.tableGamePlayers} gp, ${DatabaseContract.tablePlayers} p, ${DatabaseContract.tableScorecards} sc
      WHERE p.${DatabaseContract.columnPlayerId} = gp.${DatabaseContract.columnGpPlayerId} AND 
      g.${DatabaseContract.columnGameId} = gp.${DatabaseContract.columnGpGameId} AND 
      sc.${DatabaseContract.columnScGamePlayerId} = gp.${DatabaseContract.columnGpId} AND
      g.${DatabaseContract.columnGameId} = ?
      ORDER BY gp.${DatabaseContract.columnGpPlayerOrder} ASC
    ''',
      [gameId],
    );

    return result;
  }

  // Returns last created and still running game
  Future<List<Map<String, dynamic>>?> fetchGameByRunning() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT ${DatabaseContract.columnGameId}
      FROM ${DatabaseContract.tableGames}
      WHERE ${DatabaseContract.columnGameStatus} = ${GameStatus.running.dbValue}
      ORDER BY ${DatabaseContract.columnGameCreatedAt} DESC
      LIMIT 1
    ''');

    if (result.isEmpty) {
      return null;
    }

    final int gameId = result[0][DatabaseContract.columnGameId] as int;

    return await fetchGameById(gameId);
  }

  // Updates a ScoreField
  Future<void> updateScoreField(
    int scorecardId,
    String fieldName,
    int? score,
  ) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      // 1. Das gewünschte Feld auf dem Punktezettel aktualisieren
      await txn.update(
        DatabaseContract.tableScorecards,
        {fieldName: score},
        where: '${DatabaseContract.columnScId} = ?',
        whereArgs: [scorecardId],
      );

      // 2. Die aktualisierte Scorecard auslesen
      final scRows = await txn.query(
        DatabaseContract.tableScorecards,
        where: '${DatabaseContract.columnScId} = ?',
        whereArgs: [scorecardId],
      );

      if (scRows.isEmpty) return;
      final sc = scRows.first;

      final gamePlayerId = sc[DatabaseContract.columnScGamePlayerId] as int;

      // 3. Obere Summe & Bonus prüfen
      final ones = (sc[DatabaseContract.columnScOnes] as int?) ?? 0;
      final twos = (sc[DatabaseContract.columnScTwos] as int?) ?? 0;
      final threes = (sc[DatabaseContract.columnScThrees] as int?) ?? 0;
      final fours = (sc[DatabaseContract.columnScFours] as int?) ?? 0;
      final fives = (sc[DatabaseContract.columnScFives] as int?) ?? 0;
      final sixes = (sc[DatabaseContract.columnScSixes] as int?) ?? 0;

      final upperSum = ones + twos + threes + fours + fives + sixes;
      final upperBonus = upperSum >= 63 ? 35 : 0;

      // Upper Bonus in Scorecard speichern
      await txn.update(
        DatabaseContract.tableScorecards,
        {DatabaseContract.columnScUpperBonus: upperBonus},
        where: '${DatabaseContract.columnScId} = ?',
        whereArgs: [scorecardId],
      );

      // 4. Gesamtsumme berechnen (Unterer Bereich)
      final threeOfAKind =
          (sc[DatabaseContract.columnScThreeOfAKind] as int?) ?? 0;
      final fourOfAKind =
          (sc[DatabaseContract.columnScFourOfAKind] as int?) ?? 0;
      final fullHouse = (sc[DatabaseContract.columnScFullHouse] as int?) ?? 0;
      final smallStraight =
          (sc[DatabaseContract.columnScSmallStraight] as int?) ?? 0;
      final largeStraight =
          (sc[DatabaseContract.columnScLargeStraight] as int?) ?? 0;
      final yahtzee = (sc[DatabaseContract.columnScYahtzee] as int?) ?? 0;
      final chance = (sc[DatabaseContract.columnScChance] as int?) ?? 0;

      // 5. Total Score im GamePlayer aktualisieren
      final totalScore =
          upperSum +
          upperBonus +
          threeOfAKind +
          fourOfAKind +
          fullHouse +
          smallStraight +
          largeStraight +
          yahtzee +
          chance;

      await txn.update(
        DatabaseContract.tableGamePlayers,
        {DatabaseContract.columnGpTotalScore: totalScore},
        where: '${DatabaseContract.columnGpId} = ?',
        whereArgs: [gamePlayerId],
      );
    });
  }

  Future<void> changeActivePlayer(int gameId, int activePlayerId) async {
    final db = await _dbService.database;

    await db.update(
      DatabaseContract.tableGames,
      {DatabaseContract.columnGameCurrentPlayerId: activePlayerId},
      where: '${DatabaseContract.columnGameId} = ?',
      whereArgs: [gameId],
    );
  }

  Future<void> updateGameStatus(int gameId, GameStatus status) async {
    final db = await _dbService.database;

    await db.update(
      DatabaseContract.tableGames,
      {DatabaseContract.columnGameStatus: status.dbValue},
      where: '${DatabaseContract.columnGameId} = ?',
      whereArgs: [gameId],
    );
  }
}
