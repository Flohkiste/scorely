// lib/business/model/player.dart
import 'package:scorely/data/services/database_contract.dart';

class Player {
  final int? id;
  final String name;
  final bool isArchived;

  const Player({this.id, required this.name, this.isArchived = false});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map[DatabaseContract.columnPlayerId] as int?,
      name: map[DatabaseContract.columnPlayerName] as String,
      isArchived: map[DatabaseContract.columnPlayerIsArchived] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnPlayerId: id,
      DatabaseContract.columnPlayerName: name,
      DatabaseContract.columnPlayerIsArchived: isArchived ? 1 : 0,
    };
  }

  Player copyWith({int? id, String? name, bool? isArchived}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
