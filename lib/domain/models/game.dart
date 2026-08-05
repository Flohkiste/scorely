import 'package:scorely/data/services/database_contract.dart';

class Game {
  final int? id;
  final DateTime createdAt;
  final String status;
  final int? currentPlayerId;

  Game({
    this.id,
    DateTime? createdAt,
    this.status = 'in_progress',
    this.currentPlayerId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map[DatabaseContract.columnGameId] as int?,
      createdAt: DateTime.parse(
        map[DatabaseContract.columnGameCreatedAt] as String,
      ),
      status: map[DatabaseContract.columnGameStatus] as String,
      currentPlayerId: map[DatabaseContract.columnGameCurrentPlayerId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnGameId: id,
      DatabaseContract.columnGameCreatedAt: createdAt.toIso8601String(),
      DatabaseContract.columnGameStatus: status,
      DatabaseContract.columnGameCurrentPlayerId: currentPlayerId,
    };
  }

  Game copyWith({
    int? id,
    DateTime? createdAt,
    String? status,
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
