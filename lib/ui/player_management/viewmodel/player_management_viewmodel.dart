import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/utils/result.dart';

class PlayerManagementViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  PlayerManagementViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository {
    loadPlayersCommand = Command.createAsyncNoParam<void>(
      _loadPlayers,
      initialValue: null,
    );
    deletePlayerCommand = Command.createAsync<int, void>(
      _deletePlayer,
      initialValue: null,
    );
    activatePlayerCommand = Command.createAsync<int, void>(
      _activatePlayer,
      initialValue: null,
    );
    archivePlayerCommand = Command.createAsync(
      _archievePlayer,
      initialValue: null,
    );
  }

  late final Command<void, void> loadPlayersCommand;
  late final Command<int, void> deletePlayerCommand;
  late final Command<int, void> activatePlayerCommand;
  late final Command<int, void> archivePlayerCommand;

  List<Player> _activePlayers = [];
  List<Player> _archivedPlayers = [];

  List<Player> get activePlayers => _activePlayers;
  List<Player> get archivedPlayers => _archivedPlayers;

  Future<void> _loadPlayers() async {
    final activeResult = await _playerRepository.getActivePlayers();
    final archivedResult = await _playerRepository.getArchivedPlayers();

    // Active Players verarbeiten
    switch (activeResult) {
      case Ok(value: final players):
        _activePlayers = players;
      case Error(error: final error):
        throw error;
    }

    // Archived Players verarbeiten
    switch (archivedResult) {
      case Ok(value: final players):
        _archivedPlayers = players;
      case Error(error: final error):
        throw error;
    }

    notifyListeners();
  }

  Future<void> _archievePlayer(int playerId) async {
    final result = await _playerRepository.archivePlayer(playerId);

    switch (result) {
      case Ok():
        loadPlayersCommand.run();
      case Error(error: final error):
        throw error;
    }
  }

  Future<void> _activatePlayer(int playerId) async {
    final result = await _playerRepository.activatePlayer(playerId);

    switch (result) {
      case Ok():
        loadPlayersCommand.run();
      case Error(error: final error):
        throw error;
    }
  }

  Future<void> _deletePlayer(int playerId) async {
    final result = await _playerRepository.deletePlayer(playerId);

    switch (result) {
      case Ok():
        loadPlayersCommand.run();
      case Error(error: final error):
        throw error;
    }
  }

  Future<Result> addPlayer(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return Result.error(Exception('Name is empty'));
    }

    if (_activePlayers.any(
          (player) =>
              player.name.trim().toLowerCase() == trimmedName.toLowerCase(),
        ) ||
        _archivedPlayers.any(
          (player) =>
              player.name.trim().toLowerCase() == trimmedName.toLowerCase(),
        )) {
      return Result.error(Exception('Name already exists'));
    }
    var createResult = await _playerRepository.createPlayer(trimmedName);
    switch (createResult) {
      case Ok():
        loadPlayersCommand.run();
        return Result.ok(null);
      case Error(error: final e):
        return Result.error(e);
    }
  }
}
