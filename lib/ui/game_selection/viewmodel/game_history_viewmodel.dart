import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/domain/models/game_summary.dart';
import 'package:scorely/utils/result.dart';

class GameHistoryViewmodel extends ChangeNotifier {
  final YahtzeeRepository _yahtzeeRepository;

  GameHistoryViewmodel({required YahtzeeRepository yahtzeeRepository})
    : _yahtzeeRepository = yahtzeeRepository {
    loadHistoryCommand = Command.createAsyncNoParam<void>(
      _loadHistory,
      initialValue: null,
    );
    replayGameCommand = Command.createAsync<int, int?>(
      _replayGame,
      initialValue: null,
    );
    deleteGameCommand = Command.createAsync(_deleteGame, initialValue: null);
  }

  late final Command<void, void> loadHistoryCommand;
  late final Command<int, int?> replayGameCommand;
  late final Command<int, void> deleteGameCommand;

  List<GameSummary> _gameSummarys = [];

  List<GameSummary> get gameSummarys => _gameSummarys;

  Future<void> _loadHistory() async {
    final result = await _yahtzeeRepository.loadGameHistory();

    switch (result) {
      case Ok(value: final gameSummarys):
        _gameSummarys = gameSummarys;
      case Error(error: final error):
        throw error;
    }

    notifyListeners();
  }

  Future<int> _replayGame(int gameId) async {
    final result = await _yahtzeeRepository.replayGame(gameId);

    switch (result) {
      case Ok(value: final value):
        return value;
      case Error(error: final error):
        throw error;
    }
  }

  Future<void> _deleteGame(int gameId) async {
    final result = await _yahtzeeRepository.deleteGame(gameId);

    switch (result) {
      case Ok(value: final value):
        return value;
      case Error(error: final error):
        throw error;
    }
  }
}
