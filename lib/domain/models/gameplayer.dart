import 'package:scorely/data/services/database_contract.dart';

class GamePlayer {
  final int? id;
  final int gameId;
  final int playerId;
  final int playerOrder;
  final int totalScore;

  GamePlayer({
    this.id,
    required this.gameId,
    required this.playerId,
    required this.playerOrder,
    this.totalScore = 0,
  });

  factory GamePlayer.fromMap(Map<String, dynamic> map) {
    return GamePlayer(
      id: map[DatabaseContract.columnGpId] as int?,
      gameId: map[DatabaseContract.columnGpGameId] as int,
      playerId: map[DatabaseContract.columnGpPlayerId] as int,
      playerOrder: map[DatabaseContract.columnGpPlayerOrder] as int,
      totalScore: map[DatabaseContract.columnGpTotalScore] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnGpId: id,
      DatabaseContract.columnGpGameId: gameId,
      DatabaseContract.columnGpPlayerId: playerId,
      DatabaseContract.columnGpPlayerOrder: playerOrder,
      DatabaseContract.columnGpTotalScore: totalScore,
    };
  }

  GamePlayer copyWith({
    int? id,
    int? gameId,
    int? playerId,
    int? playerOrder,
    int? totalScore,
  }) {
    return GamePlayer(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      playerOrder: playerOrder ?? this.playerOrder,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}
