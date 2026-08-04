import 'package:flutter/material.dart';
import 'package:scorely/business/model/player.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/utils/result.dart';

class ScoreTrackingViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  ScoreTrackingViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository;

  List<Player> _players = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter
  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get selectedPlayerIds => _playerRepository.selectedPlayerIds;
  List<Player> get selectedPlayers => _players
      .where((p) => p.id != null && selectedPlayerIds.contains(p.id))
      .toList();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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
}
