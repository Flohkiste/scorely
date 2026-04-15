import 'package:flutter/material.dart';
import 'package:flutter_logcat/flutter_logcat.dart';

class PlayerSelectionViewmodel extends ChangeNotifier {
  final List<String> _players = ['Test1', 'Test2', 'Test3', 'Test4', 'Test5'];
  final List<String> _selectedPlayers = [];

  List<String> get players => _players;
  List<String> get selectedPlayers => _selectedPlayers;

  void addPlayer(String playerName) {
    // Popup zur Spieler Name eingabe + evtl. Farbe
    _players.add(playerName);
    notifyListeners();
  }

  void deletePlayer(String playerName) {
    _players.remove(playerName);
    notifyListeners();
  }

  bool isSelected(String playerName) {
    return _selectedPlayers.contains(playerName);
  }

  bool isReadyToStart() {
    return _selectedPlayers.length >= 2;
  }

  void toggleSelectPlayer(String playerName) {
    // Spielername Button wird geändert
    if (_selectedPlayers.contains(playerName)) {
      _selectedPlayers.remove(playerName);
    } else {
      _selectedPlayers.add(playerName);
    }

    Log.i('Selected Players: $selectedPlayers');

    notifyListeners();
  }

  void savePlayers() {} //TODO: Save Players
  void fetchPlayers() {} //TODO: Fetch Players
}
