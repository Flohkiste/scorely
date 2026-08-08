import 'package:flutter/material.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/utils/result.dart';

class GameSelectionViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;
  final YahtzeeRepository _yahtzeeRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GameSelectionViewmodel({
    required PlayerRepository playerRepository,
    required YahtzeeRepository yahtzeeRepository,
  }) : _playerRepository = playerRepository,
       _yahtzeeRepository = yahtzeeRepository;

  Future<Result<int>> startGame() async {
    _isLoading = true;
    notifyListeners();

    final playerIds = _playerRepository.selectedPlayerIds;

    final result = await _yahtzeeRepository.createGame(playerIds.toList());

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
