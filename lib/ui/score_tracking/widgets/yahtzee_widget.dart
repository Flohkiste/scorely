import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/scorecard.dart';
import 'package:scorely/ui/score_tracking/viewmodel/yahtzee_viewmodel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// 1. Äußeres Widget: Erstellt nur den Provider
class YahtzeeWidget extends StatelessWidget {
  const YahtzeeWidget({super.key, required this.gameId});
  final int gameId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YahtzeeViewmodel>(
      create: (context) => YahtzeeViewmodel(
        gameId: gameId,
        yahtzeeRepository: context.read<YahtzeeRepository>(),
      )..loadGame(),
      child: const _YahtzeeGameView(),
    );
  }
}

// 2. Inneres Widget: Hat Zugriff auf den Provider UND verwaltet den PageController
class _YahtzeeGameView extends StatefulWidget {
  const _YahtzeeGameView();

  @override
  State<_YahtzeeGameView> createState() => _YahtzeeGameViewState();
}

class _YahtzeeGameViewState extends State<_YahtzeeGameView> {
  late final PageController _pageController;
  YahtzeeViewmodel? _viewmodel;

  bool _dialogShown = false;
  int _currentPage = 0;
  int? _lastActivePlayerId; // Verhindert mehrfaches Scrollen

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<YahtzeeViewmodel>();
    if (_viewmodel != vm) {
      _viewmodel?.removeListener(_onViewModelChanged);
      _viewmodel = vm;
      _viewmodel?.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    _viewmodel?.removeListener(_onViewModelChanged);
    _pageController.dispose();
    super.dispose();
  }

  // Hier verarbeiten wir alle Side-Effects (Scrollen, Dialoge)
  void _onViewModelChanged() {
    final vm = _viewmodel;
    if (vm == null) return;

    // A: GameOver-Dialog
    if (!vm.isGameRunning && vm.winnerName != null && !_dialogShown) {
      _dialogShown = true;
      _showGameOverDialog(context, vm.winnerName!);
    }

    // B: Automatisch zum aktiven Spieler scrollen
    final currentPlayerId = vm.currentPlayerId;
    if (currentPlayerId != null && currentPlayerId != _lastActivePlayerId) {
      // Erst nach dem aktuellen Frame scrollen (wenn das PageView sicher gezeichnet ist!)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final targetIndex = vm.game?.getPlayerIndex(currentPlayerId);

        if (targetIndex != null && _pageController.hasClients) {
          _lastActivePlayerId = currentPlayerId; // Nur bei Erfolg aktualisieren

          _pageController.animateToPage(
            targetIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer kümmert sich NUR noch um das Zeichnen der UI
    return Consumer<YahtzeeViewmodel>(
      builder: (context, viewmodel, child) {
        if (viewmodel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewmodel.errorMessage != null) {
          return Center(child: Text('Error: ${viewmodel.errorMessage}'));
        }

        if (viewmodel.game == null) {
          return const Center(child: Text('Keine Spieldaten verfügbar'));
        }

        final totalSessions = viewmodel.game!.sessions.length;
        final safeIndex = _currentPage.clamp(0, totalSessions - 1);
        final currentSession = viewmodel.game!.sessions[safeIndex];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _Header(
                playerName: currentSession.player.name,
                pageController: _pageController,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalSessions,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _TableById(
                      playerScorecard: viewmodel.game!.sessions[index],
                      updateScoreFieldCommand:
                          viewmodel.updateScoreFieldCommand,
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: totalSessions,
                effect: const WormEffect(),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGameOverDialog(BuildContext context, String winnerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('$winnerName has won'),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hilfswidgets (Aufgeräumt ohne unnötige Context-Parameter)
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String _playerName;
  final PageController _pageController;

  const _Header({
    required String playerName,
    required PageController pageController,
  }) : _playerName = playerName,
       _pageController = pageController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_left),
          ),
          Text(_playerName, style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}

class _TableById extends StatelessWidget {
  final PlayerGameSession _playerGameSession;
  final Command<(int scorecardId, String fieldName, int? score), void>
  _updateScoreFieldCommand;

  const _TableById({
    required PlayerGameSession playerScorecard,
    required Command<(int scorecardId, String fieldName, int? score), void>
    updateScoreFieldCommand,
  }) : _playerGameSession = playerScorecard,
       _updateScoreFieldCommand = updateScoreFieldCommand;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            const TableCell(child: Center(child: Text(""))),
            _InfoTableCell(info: _playerGameSession.player.name),
          ],
        ),
        _buildScoreRow('ONES', (sc) => sc.ones, DatabaseContract.columnScOnes),
        _buildScoreRow('TWOS', (sc) => sc.twos, DatabaseContract.columnScTwos),
        _buildScoreRow(
          'THREES',
          (sc) => sc.threes,
          DatabaseContract.columnScThrees,
        ),
        _buildScoreRow(
          'FOURS',
          (sc) => sc.fours,
          DatabaseContract.columnScFours,
        ),
        _buildScoreRow(
          'FIVES',
          (sc) => sc.fives,
          DatabaseContract.columnScFives,
        ),
        _buildScoreRow(
          'SIXES',
          (sc) => sc.sixes,
          DatabaseContract.columnScSixes,
        ),
        _buildScoreRow(
          'THREE OF A KIND',
          (sc) => sc.threeOfAKind,
          DatabaseContract.columnScThreeOfAKind,
        ),
        _buildScoreRow(
          'FOUR OF A KIND',
          (sc) => sc.fourOfAKind,
          DatabaseContract.columnScFourOfAKind,
        ),
        _buildScoreRow(
          'FULL HOUSE',
          (sc) => sc.fullHouse,
          DatabaseContract.columnScFullHouse,
        ),
        _buildScoreRow(
          'SMALL STRAIGHT',
          (sc) => sc.smallStraight,
          DatabaseContract.columnScSmallStraight,
        ),
        _buildScoreRow(
          'LARGE STRAIGHT',
          (sc) => sc.largeStraight,
          DatabaseContract.columnScLargeStraight,
        ),
        _buildScoreRow(
          'YAHTZEE',
          (sc) => sc.yahtzee,
          DatabaseContract.columnScYahtzee,
        ),
        _buildScoreRow(
          'CHANCE',
          (sc) => sc.chance,
          DatabaseContract.columnScChance,
        ),
      ],
    );
  }

  TableRow _buildScoreRow(
    String title,
    int? Function(Scorecard) getScore,
    String fieldName,
  ) {
    final scorecard = _playerGameSession.scorecard;
    final score = getScore(scorecard);
    return TableRow(
      children: [
        _InfoTableCell(info: title),
        _ScoreFieldCell(
          value: score != null ? '$score' : '_',
          scorecardId: scorecard.id as int,
          fieldName: fieldName,
        ),
      ],
    );
  }
}

class _ScoreFieldCell extends StatelessWidget {
  const _ScoreFieldCell({
    required this.value,
    required this.scorecardId,
    required this.fieldName,
  });

  final String value;
  final int scorecardId;
  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: GestureDetector(
        child: Center(child: Text(value)),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) => _InputDialog(
              viewmodel: context.read<YahtzeeViewmodel>(),
              scorecardId: scorecardId,
              databaseFieldName: fieldName,
            ),
          );
        },
      ),
    );
  }
}

class _InfoTableCell extends StatelessWidget {
  const _InfoTableCell({required this.info, this.bold = true});

  final String info;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Center(
        child: Text(
          info,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    required this.viewmodel,
    required this.scorecardId,
    required this.databaseFieldName,
  });

  final YahtzeeViewmodel viewmodel;
  final int scorecardId;
  final String databaseFieldName;

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('input score'),
      content: TextField(
        controller: _textFieldController,
        decoration: const InputDecoration(hintText: 'score'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(_textFieldController.text);
            if (value == null) return;
            widget.viewmodel.updateScoreFieldCommand.run((
              widget.scorecardId,
              widget.databaseFieldName,
              value,
            ));
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
