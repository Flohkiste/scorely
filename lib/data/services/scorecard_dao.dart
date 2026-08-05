import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/data/services/database_service.dart';

class ScorecardDao {
  final DatabaseService _dbService;

  ScorecardDao({required DatabaseService dbService}) : _dbService = dbService;

  /// Lädt die Scorecard für einen bestimmten Eintrag in `game_players`.
  Future<Map<String, dynamic>?> fetchByGamePlayerId(int gamePlayerId) async {
    final db = await _dbService.database;
    final results = await db.query(
      DatabaseContract.tableScorecards,
      where: '${DatabaseContract.columnScGamePlayerId} = ?',
      whereArgs: [gamePlayerId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Trägt einen Punktestand für eine bestimmte Spalte (z. B. columnScOnes, columnScFullHouse) ein.
  /// Berechnet danach automatisch den oberen Bonus und aktualisiert die Gesamtsumme in `game_players`.
  Future<void> updateCategoryScore({
    required int gamePlayerId,
    required String columnName,
    required int? scoreValue,
  }) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      // 1. Das ausgewählte Feld auf der Scorecard aktualisieren
      await txn.update(
        DatabaseContract.tableScorecards,
        {columnName: scoreValue},
        where: '${DatabaseContract.columnScGamePlayerId} = ?',
        whereArgs: [gamePlayerId],
      );

      // 2. Aktuellen Zustand der Scorecard abrufen
      final scorecardResult = await txn.query(
        DatabaseContract.tableScorecards,
        where: '${DatabaseContract.columnScGamePlayerId} = ?',
        whereArgs: [gamePlayerId],
        limit: 1,
      );

      if (scorecardResult.isEmpty) return;
      final sc = scorecardResult.first;

      // 3. Oberen Teil berechnen (Ones bis Sixes)
      final ones = (sc[DatabaseContract.columnScOnes] as int?) ?? 0;
      final twos = (sc[DatabaseContract.columnScTwos] as int?) ?? 0;
      final threes = (sc[DatabaseContract.columnScThrees] as int?) ?? 0;
      final fours = (sc[DatabaseContract.columnScFours] as int?) ?? 0;
      final fives = (sc[DatabaseContract.columnScFives] as int?) ?? 0;
      final sixes = (sc[DatabaseContract.columnScSixes] as int?) ?? 0;

      final upperSum = ones + twos + threes + fours + fives + sixes;
      final upperBonus = upperSum >= 63 ? 35 : 0;

      // Bonus in der Scorecard speichern
      await txn.update(
        DatabaseContract.tableScorecards,
        {DatabaseContract.columnScUpperBonus: upperBonus},
        where: '${DatabaseContract.columnScGamePlayerId} = ?',
        whereArgs: [gamePlayerId],
      );

      // 4. Unteren Teil berechnen
      final threeOfAKind =
          (sc[DatabaseContract.columnScThreeOfAKind] as int?) ?? 0;
      final fourOfAKind =
          (sc[DatabaseContract.columnScFourOfAKind] as int?) ?? 0;
      final fullHouse = (sc[DatabaseContract.columnScFullHouse] as int?) ?? 0;
      final smallStraight =
          (sc[DatabaseContract.columnScSmallStraight] as int?) ?? 0;
      final largeStraight =
          (sc[DatabaseContract.columnScLargeStraight] as int?) ?? 0;
      final kniffel = (sc[DatabaseContract.columnScKniffel] as int?) ?? 0;
      final chance = (sc[DatabaseContract.columnScChance] as int?) ?? 0;

      final lowerSum =
          threeOfAKind +
          fourOfAKind +
          fullHouse +
          smallStraight +
          largeStraight +
          kniffel +
          chance;

      // 5. Gesamtsumme berechnen und in `game_players` schreiben
      final totalScore = upperSum + upperBonus + lowerSum;

      await txn.update(
        DatabaseContract.tableGamePlayers,
        {DatabaseContract.columnGpTotalScore: totalScore},
        where: '${DatabaseContract.columnGpId} = ?',
        whereArgs: [gamePlayerId],
      );
    });
  }

  /// Prüft, ob die Scorecard eines Spielers vollständig ausgefüllt ist (13 Felder).
  Future<bool> isScorecardComplete(int gamePlayerId) async {
    final sc = await fetchByGamePlayerId(gamePlayerId);
    if (sc == null) return false;

    final categories = [
      DatabaseContract.columnScOnes,
      DatabaseContract.columnScTwos,
      DatabaseContract.columnScThrees,
      DatabaseContract.columnScFours,
      DatabaseContract.columnScFives,
      DatabaseContract.columnScSixes,
      DatabaseContract.columnScThreeOfAKind,
      DatabaseContract.columnScFourOfAKind,
      DatabaseContract.columnScFullHouse,
      DatabaseContract.columnScSmallStraight,
      DatabaseContract.columnScLargeStraight,
      DatabaseContract.columnScKniffel,
      DatabaseContract.columnScChance,
    ];

    // Wenn kein Feld mehr `null` ist, ist die Karte voll
    return categories.every((column) => sc[column] != null);
  }
}
