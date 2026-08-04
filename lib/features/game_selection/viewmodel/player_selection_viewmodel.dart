import 'package:flutter/material.dart';

import 'package:flutter_logcat/flutter_logcat.dart';
import 'package:scorely/business/model/player.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/utils/result.dart';

class PlayerSelectionViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  PlayerSelectionViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository;

  List<Player> _players = [];
  final Set<int> _selectedPlayerIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getter
  List<Player> get players => _players;
  List<Player> get selectedPlayers => _players
      .where((p) => p.id != null && _selectedPlayerIds.contains(p.id))
      .toList();
  Set<int> get selectedPlayerIds => _selectedPlayerIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lädt alle Spieler aus der Datenbank in `_allPlayers`.
  Future<void> loadPlayers() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _playerRepository.getPlayers();

    switch (result) {
      case Ok(value: final loadPlayers):
        _players = loadPlayers;
      case Error(error: final e):
        _errorMessage = 'Fehler beim Laden der Spieler: $e';
    }

    _setLoading(false);
  }

  /// Erstellt einen neuen Spieler in der DB und fügt ihn der Liste hinzu.
  /// Gibt `true` zurück, wenn das Speichern erfolgreich war.
  Future<Result> addPlayer(String name) async {
    // TODO: Name validieren, Repo aufrufen, _allPlayers aktualisieren, notifyListeners()

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return Result.error(Exception('Name is empty'));
    }

    if (_players.any(
      (player) => player.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    )) {
      return Result.error(Exception('Name already exists'));
    }
    var createResult = await _playerRepository.createPlayer(trimmedName);
    switch (createResult) {
      case Ok():
        await loadPlayers();
        return Result.ok(null);
      case Error(error: final e):
        _errorMessage = 'Fehler beim Erstellen des Spielers: $e';
        notifyListeners();
        return Result.error(e);
    }
  }

  Future<Result<void>> deletePlayer(int playerId) async {
    final result = await _playerRepository.deletePlayer(playerId);

    switch (result) {
      case Ok():
        await loadPlayers();
      case Error(error: final e):
        _errorMessage = 'Fehler beim Löschen des Spielers: $e';
        notifyListeners();
    }

    return result;
  }

  /// Wählt einen Spieler aus oder hebt die Auswahl auf (Toggle).
  void togglePlayerSelection(int playerId) {
    if (_selectedPlayerIds.contains(playerId)) {
      _selectedPlayerIds.remove(playerId);
    } else {
      _selectedPlayerIds.add(playerId);
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isSelected(int playerId) {
    return _selectedPlayerIds.contains(playerId);
  }
}
