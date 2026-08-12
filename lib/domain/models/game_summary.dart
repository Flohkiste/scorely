import 'package:scorely/domain/models/game_status.dart';

class PlayerScore {
  final String name;
  final int score;

  const PlayerScore({required this.name, required this.score});

  factory PlayerScore.fromMap(Map<String, dynamic> map) {
    return PlayerScore(
      name: (map['player_name'] ?? map['name']) as String,
      score: (map['total_score'] ?? map['score']) as int,
    );
  }
}

class GameSummary {
  final int id;
  final DateTime createdAt;
  final GameStatus status;
  final int totalPlayers;
  final List<PlayerScore> topThreePlayers;

  const GameSummary({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalPlayers,
    required this.topThreePlayers,
  });

  factory GameSummary.fromMap(Map<String, dynamic> map) {
    // Parst das Datum flexibel (egal ob bereits DateTime oder ISO-String)
    final rawDate = map['created_at'] ?? map['createdAt'];
    final parsedDate = rawDate is DateTime
        ? rawDate
        : DateTime.parse(rawDate as String);

    // Parst die Top-3-Spieler als Liste
    final rawTopPlayers =
        (map['top_players'] ?? map['topThreePlayers']) as List<dynamic>? ?? [];
    final topPlayersList = rawTopPlayers
        .map((p) => PlayerScore.fromMap(p as Map<String, dynamic>))
        .toList();

    return GameSummary(
      id: (map['game_id'] ?? map['id']) as int,
      createdAt: parsedDate,
      // Nutzt dbValue (int) aus deinem GameStatus Enum
      status: GameStatus.fromDbValue(map['status'] as String),
      totalPlayers: (map['total_players'] ?? map['totalPlayers']) as int,
      topThreePlayers: topPlayersList,
    );
  }

  GameSummary copyWith({
    int? id,
    DateTime? createdAt,
    GameStatus? status,
    int? totalPlayers,
    List<PlayerScore>? topThreePlayers,
  }) {
    return GameSummary(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      topThreePlayers: topThreePlayers ?? this.topThreePlayers,
    );
  }
}
