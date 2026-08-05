import 'package:scorely/data/services/database_contract.dart';

class Scorecard {
  final int? id;
  final int gamePlayerId;

  // Oberer Teil
  final int? ones;
  final int? twos;
  final int? threes;
  final int? fours;
  final int? fives;
  final int? sixes;
  final int upperBonus;

  // Unterer Teil
  final int? threeOfAKind;
  final int? fourOfAKind;
  final int? fullHouse;
  final int? smallStraight;
  final int? largeStraight;
  final int? kniffel;
  final int? chance;

  Scorecard({
    this.id,
    required this.gamePlayerId,
    this.ones,
    this.twos,
    this.threes,
    this.fours,
    this.fives,
    this.sixes,
    this.upperBonus = 0,
    this.threeOfAKind,
    this.fourOfAKind,
    this.fullHouse,
    this.smallStraight,
    this.largeStraight,
    this.kniffel,
    this.chance,
  });

  /// Berechnet die Summe des oberen Teils (ohne Bonus)
  int get upperScore {
    return (ones ?? 0) +
        (twos ?? 0) +
        (threes ?? 0) +
        (fours ?? 0) +
        (fives ?? 0) +
        (sixes ?? 0);
  }

  /// Prüft, ob der Bonus (>= 63 Punkte im oberen Teil) erreicht wurde
  int get calculatedUpperBonus => upperScore >= 63 ? 35 : 0;

  /// Berechnet die Gesamtsumme der Scorecard
  int get calculatedTotalScore {
    final lowerScore =
        (threeOfAKind ?? 0) +
        (fourOfAKind ?? 0) +
        (fullHouse ?? 0) +
        (smallStraight ?? 0) +
        (largeStraight ?? 0) +
        (kniffel ?? 0) +
        (chance ?? 0);

    return upperScore + calculatedUpperBonus + lowerScore;
  }

  factory Scorecard.fromMap(Map<String, dynamic> map) {
    return Scorecard(
      id: map[DatabaseContract.columnScId] as int?,
      gamePlayerId: map[DatabaseContract.columnScGamePlayerId] as int,
      ones: map[DatabaseContract.columnScOnes] as int?,
      twos: map[DatabaseContract.columnScTwos] as int?,
      threes: map[DatabaseContract.columnScThrees] as int?,
      fours: map[DatabaseContract.columnScFours] as int?,
      fives: map[DatabaseContract.columnScFives] as int?,
      sixes: map[DatabaseContract.columnScSixes] as int?,
      upperBonus: map[DatabaseContract.columnScUpperBonus] as int? ?? 0,
      threeOfAKind: map[DatabaseContract.columnScThreeOfAKind] as int?,
      fourOfAKind: map[DatabaseContract.columnScFourOfAKind] as int?,
      fullHouse: map[DatabaseContract.columnScFullHouse] as int?,
      smallStraight: map[DatabaseContract.columnScSmallStraight] as int?,
      largeStraight: map[DatabaseContract.columnScLargeStraight] as int?,
      kniffel: map[DatabaseContract.columnScKniffel] as int?,
      chance: map[DatabaseContract.columnScChance] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnScId: id,
      DatabaseContract.columnScGamePlayerId: gamePlayerId,
      DatabaseContract.columnScOnes: ones,
      DatabaseContract.columnScTwos: twos,
      DatabaseContract.columnScThrees: threes,
      DatabaseContract.columnScFours: fours,
      DatabaseContract.columnScFives: fives,
      DatabaseContract.columnScSixes: sixes,
      DatabaseContract.columnScUpperBonus: calculatedUpperBonus,
      DatabaseContract.columnScThreeOfAKind: threeOfAKind,
      DatabaseContract.columnScFourOfAKind: fourOfAKind,
      DatabaseContract.columnScFullHouse: fullHouse,
      DatabaseContract.columnScSmallStraight: smallStraight,
      DatabaseContract.columnScLargeStraight: largeStraight,
      DatabaseContract.columnScKniffel: kniffel,
      DatabaseContract.columnScChance: chance,
    };
  }

  Scorecard copyWith({
    int? id,
    int? gamePlayerId,
    int? ones,
    int? twos,
    int? threes,
    int? fours,
    int? fives,
    int? sixes,
    int? upperBonus,
    int? threeOfAKind,
    int? fourOfAKind,
    int? fullHouse,
    int? smallStraight,
    int? largeStraight,
    int? kniffel,
    int? chance,
  }) {
    return Scorecard(
      id: id ?? this.id,
      gamePlayerId: gamePlayerId ?? this.gamePlayerId,
      ones: ones ?? this.ones,
      twos: twos ?? this.twos,
      threes: threes ?? this.threes,
      fours: fours ?? this.fours,
      fives: fives ?? this.fives,
      sixes: sixes ?? this.sixes,
      upperBonus: upperBonus ?? this.upperBonus,
      threeOfAKind: threeOfAKind ?? this.threeOfAKind,
      fourOfAKind: fourOfAKind ?? this.fourOfAKind,
      fullHouse: fullHouse ?? this.fullHouse,
      smallStraight: smallStraight ?? this.smallStraight,
      largeStraight: largeStraight ?? this.largeStraight,
      kniffel: kniffel ?? this.kniffel,
      chance: chance ?? this.chance,
    );
  }
}
