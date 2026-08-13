import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/utils/result.dart';

class YahtzeeViewmodel extends ChangeNotifier {
  final int _gameId;
  final IYahtzeeRepository _yahtzeeRepository;

  GameDetail? _game;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGameRunning = true;
  String? _winnerName;
  int? _currentPlayerId;

  YahtzeeViewmodel({
    required int gameId,
    required IYahtzeeRepository yahtzeeRepository,
  }) : _gameId = gameId,
       _yahtzeeRepository = yahtzeeRepository {
    updateScoreFieldCommand =
        Command.createAsyncNoResult<
          (int scorecardId, String fieldName, int? score)
        >((param) => _updateScoreField(param.$1, param.$2, param.$3));
  }

  late final Command<(int scorecardId, String fieldName, int? score), void>
  updateScoreFieldCommand;

  // Getters für den UI-Zustand
  GameDetail? get game => _game;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get gameId => _game!.game.id;
  bool get isGameRunning => _isGameRunning;
  String? get winnerName => _winnerName;
  int? get currentPlayerId => _currentPlayerId;

  Future<void> loadGame() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _yahtzeeRepository.loadGameById(_gameId);

    switch (result) {
      case Ok(value: final game):
        _game = game;
        _errorMessage = null;
      case Error(error: final e):
        _game = null;
        _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Player> getPlayers() {
    List<Player> result = [];

    if (game == null) {
      return result;
    }

    for (var session in game!.sessions) {
      result.add(session.player);
    }
    return result;
  }

  Future<void> loadCurrentPlayerId() async {
    final result = await _yahtzeeRepository.getCurrentPlayerId(_gameId);

    switch (result) {
      case Ok(value: final id):
        _errorMessage = null;
        _currentPlayerId = id;
      case Error(error: final e):
        _errorMessage = e.toString();
        throw e;
    }
  }

  Future<void> _updateScoreField(
    int scorecardId,
    String fieldName,
    int? score,
  ) async {
    final result = await _yahtzeeRepository.updateScoreField(
      scorecardId,
      fieldName,
      score!,
    );

    if (result is Error) {
      _errorMessage = (result).error.toString();
      notifyListeners();
      return;
    }

    await loadGame();

    final finishedResult = await _yahtzeeRepository.isGameFinished(_gameId);
    if (finishedResult is Ok<bool> && finishedResult.value) {
      await _yahtzeeRepository.endGame(_gameId);
      _isGameRunning = false;
      _determineWinner();
    }

    await _yahtzeeRepository.changeActivePlayer(_gameId);
    loadCurrentPlayerId();

    notifyListeners();
  }

  void _determineWinner() {
    if (_game == null || _game!.sessions.isEmpty) return;

    PlayerGameSession? winnerSession;
    int highestScore = -1;

    for (final session in _game!.sessions) {
      if (session.gamePlayer.totalScore > highestScore) {
        highestScore = session.gamePlayer.totalScore;
        winnerSession = session;
      }
    }

    _winnerName = winnerSession?.player.name;
  }

  Future<bool> isGameFinished() async {
    final result = await _yahtzeeRepository.isGameFinished(_gameId);

    switch (result) {
      case Ok(value: final isFinished):
        return isFinished;
      case Error(error: final e):
        _errorMessage = e.toString();
        notifyListeners();
        return false;
    }
  }
}
