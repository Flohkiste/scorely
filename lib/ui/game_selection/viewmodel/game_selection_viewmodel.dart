import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/utils/result.dart';

class GameSelectionViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GameSelectionViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository;

  Future<Result<void>> startGame() async {
    return Result.ok(null);
  }
}
