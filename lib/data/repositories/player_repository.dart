import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/data/daos/player_dao.dart';
import 'package:scorely/utils/result.dart';

abstract class IPlayerRepository {
  Future<Result<List<Player>>> getPlayers();
  Future<Result<Player>> getPlayerById(int id);
  Future<Result<List<Player>>> getArchivedPlayers();
  Future<Result<List<Player>>> getActivePlayers();
  Future<Result<Player>> createPlayer(String name);
  Future<Result<void>> deletePlayer(int id);
  Future<Result<void>> archivePlayer(int playerId);
  Future<Result<void>> activatePlayer(int playerId);
}

class PlayerRepository implements IPlayerRepository {
  final PlayerDao _playerDao;

  PlayerRepository({required PlayerDao playerDao}) : _playerDao = playerDao;

  // In Memory State
  final ValueNotifier<Set<int>> _selectedPlayerIds = ValueNotifier<Set<int>>(
    {},
  );

  ValueListenable<Set<int>> get selectedPlayerIdsNotifier => _selectedPlayerIds;

  Set<int> get selectedPlayerIds => _selectedPlayerIds.value;

  // Methoden - In-Memory

  void togglePlayerSelection(int playerId) {
    final currentSet = Set<int>.from(_selectedPlayerIds.value);

    if (currentSet.contains(playerId)) {
      currentSet.remove(playerId);
    } else {
      currentSet.add(playerId);
    }

    _selectedPlayerIds.value = currentSet;
  }

  // Methoden - Datenbank
  @override
  Future<Result<Player>> createPlayer(String name) async {
    try {
      final playerToInsert = Player(name: name);
      final generatedId = await _playerDao.insert(playerToInsert.toMap());

      final createdPlayer = playerToInsert.copyWith(id: generatedId);
      return Result.ok(createdPlayer);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deletePlayer(int id) async {
    try {
      final rowsAffected = await _playerDao.delete(id);
      if (rowsAffected > 0) {
        return Result.ok(null);
      } else {
        throw Exception('Player with id $id not found');
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Player>> getPlayerById(int id) {
    // TODO: implement getPlayerById
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Player>>> getPlayers() async {
    try {
      final rawMaps = await _playerDao.fetchAll();
      final players = rawMaps.map((map) => Player.fromMap(map)).toList();
      return Result.ok(players);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Player>>> getActivePlayers() async {
    try {
      final rawMaps = await _playerDao.fetchActive();
      final players = rawMaps.map((map) => Player.fromMap(map)).toList();
      return Result.ok(players);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Player>>> getArchivedPlayers() async {
    try {
      final rawMaps = await _playerDao.fetchArchived();
      final players = rawMaps.map((map) => Player.fromMap(map)).toList();
      return Result.ok(players);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> activatePlayer(int playerId) async {
    try {
      await _playerDao.setArchivedStatus(playerId, false);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> archivePlayer(int playerId) async {
    try {
      await _playerDao.setArchivedStatus(playerId, true);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
