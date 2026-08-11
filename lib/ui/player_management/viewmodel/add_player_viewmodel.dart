import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/utils/result.dart';

class AddPlayerViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  late final Command<void, Player?> addPlayerCommand;
  final TextEditingController nameController = TextEditingController();

  AddPlayerViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository {
    addPlayerCommand = Command.createAsyncNoParam<Player?>(
      _createPlayer,
      initialValue: null,
    );

    // Verbindet Command-Zustände mit dem UI-Rebuild
    addPlayerCommand.errors.addListener(notifyListeners);
    addPlayerCommand.isRunning.addListener(notifyListeners);

    // Löscht Fehlermeldung, sobald der Nutzer anfängt zu tippen
    nameController.addListener(_clearErrorOnTyping);
  }

  void _clearErrorOnTyping() {
    if (addPlayerCommand.errors.value != null) {
      addPlayerCommand.clearErrors();
    }
  }

  Future<Player> _createPlayer() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      throw Exception("name can't be empty");
    }

    // Sauberes Pattern Matching für den Result-Type
    final existingPlayersResult = await _playerRepository.getPlayers();
    if (existingPlayersResult case Ok(value: final players)) {
      final exists = players.any(
        (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
      );
      if (exists) {
        throw Exception("player already exist's");
      }
    }

    final result = await _playerRepository.createPlayer(name);

    switch (result) {
      case Ok(value: final newPlayer):
        return newPlayer;
      case Error(error: final e):
        throw e;
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_clearErrorOnTyping);
    nameController.dispose();
    addPlayerCommand.errors.removeListener(notifyListeners);
    addPlayerCommand.isRunning.removeListener(notifyListeners);
    addPlayerCommand.dispose(); // WICHTIG: Command aufräumen
    super.dispose();
  }
}
