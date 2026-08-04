// lib/business/model/player.dart
import 'package:scorely/data/services/database_contract.dart';

class Player {
  final int? id;
  final String name;

  const Player({this.id, required this.name});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map[DatabaseContract.columnPlayerId] as int?,
      name: map[DatabaseContract.columnPlayerName] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseContract.columnPlayerId: id,
      DatabaseContract.columnPlayerName: name,
    };
  }

  Player copyWith({int? id, String? name}) {
    return Player(id: id ?? this.id, name: name ?? this.name);
  }
}
