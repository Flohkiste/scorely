import 'package:flutter/foundation.dart';
import 'package:scorely/domain/models/player/player.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/utils/result.dart';

/// Abstrakte Oberklasse für alle spielspezifischen ViewModels in Scorely.
abstract class GameViewModel extends ChangeNotifier {
  final PlayerRepository playerRepository;

  GameViewModel({required this.playerRepository});

  List<Player> _players = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter
  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get selectedPlayerIds => playerRepository.selectedPlayerIds;

  /// Liefert nur die aktuell für das Spiel ausgewählten Spieler zurück.
  List<Player> get selectedPlayers => _players
      .where((p) => p.id != null && selectedPlayerIds.contains(p.id))
      .toList();

  /// Steuert den Ladezustand und benachrichtigt bei Änderung die Listener.
  @protected
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Setzt oder löscht eine Fehlermeldung und benachrichtigt die Listener.
  @protected
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Lädt die Spielerliste aus dem PlayerRepository.
  Future<void> loadPlayers() async {
    setLoading(true);
    _errorMessage = null;

    final result = await playerRepository.getPlayers();

    switch (result) {
      case Ok(value: final loadedPlayers):
        _players = loadedPlayers;
      case Error(error: final e):
        _errorMessage = 'Fehler beim Laden der Spieler: $e';
    }

    setLoading(false);
  }

  /// Optionales Hook für Kindklassen, um bei einem Spiel-Reset
  /// den Zustand zurückzusetzen.
  @mustCallSuper
  void resetGame() {
    _errorMessage = null;
    notifyListeners();
  }
}
