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
  }

  Future<Player> _createPlayer() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      throw Exception("name can't be empty");
    }

    final existingPlayersResult = await _playerRepository.getPlayers();
    if (existingPlayersResult is Ok<List<Player>>) {
      final exists = existingPlayersResult.value.any(
        (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
      );
      if (exists) {
        throw Exception("Spielername existiert bereits");
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
    nameController.dispose();
    super.dispose();
  }
}
