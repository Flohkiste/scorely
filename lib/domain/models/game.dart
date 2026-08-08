import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/domain/models/game_status.dart';

class Game {
  final int? id;
  final DateTime createdAt;
  final GameStatus status;
  final int? currentPlayerId;

  Game({
    this.id,
    DateTime? createdAt,
    this.status = GameStatus.running,
    this.currentPlayerId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map[DatabaseContract.columnGameId] as int?,
      createdAt: DateTime.parse(
        map[DatabaseContract.columnGameCreatedAt] as String,
      ),
      status: GameStatus.fromDbValue(
        map[DatabaseContract.columnGameStatus] as String,
      ),
      currentPlayerId: map[DatabaseContract.columnGameCurrentPlayerId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnGameId: id,
      DatabaseContract.columnGameCreatedAt: createdAt.toIso8601String(),
      DatabaseContract.columnGameStatus: status.dbValue,
      DatabaseContract.columnGameCurrentPlayerId: currentPlayerId,
    };
  }

  Game copyWith({
    int? id,
    DateTime? createdAt,
    GameStatus? status,
    int? currentPlayerId,
  }) {
    return Game(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
    );
  }
}
