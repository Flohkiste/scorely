import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/data/services/database_contract.dart';
import 'package:scorely/domain/models/game_detail.dart';
import 'package:scorely/domain/models/scorecard.dart';
import 'package:scorely/ui/score_tracking/viewmodel/yahtzee_viewmodel.dart';

class YahtzeeWidget extends StatefulWidget {
  const YahtzeeWidget({super.key, required this.gameId});
  final int gameId;

  @override
  State<YahtzeeWidget> createState() => _YahtzeeWidgetState();
}

class _YahtzeeWidgetState extends State<YahtzeeWidget> {
  bool _dialogShown = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YahtzeeViewmodel>(
      create: (context) =>
          YahtzeeViewmodel(
              gameId: widget.gameId,
              yahtzeeRepository: context.read<YahtzeeRepository>(),
            )
            ..loadGame()
            ..loadCurrentPlayerId(),
      child: Consumer<YahtzeeViewmodel>(
        builder: (context, viewmodel, child) {
          if (viewmodel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewmodel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Error: ${viewmodel.errorMessage}')],
              ),
            );
          }

          if (viewmodel.game == null) {
            return const Center(child: Text('Keine Spieldaten verfügbar'));
          }

          if (!viewmodel.isGameRunning &&
              viewmodel.winnerName != null &&
              !_dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _dialogShown = true;
              _showGameOverDialog(context, viewmodel.winnerName!);
            });
          }

          if (viewmodel.currentPlayerId != null) {
            final activeIndex = viewmodel.game!.getPlayerIndex(
              viewmodel.currentPlayerId!,
            );
            if (activeIndex != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pageController.hasClients &&
                    _pageController.page?.round() != activeIndex) {
                  _pageController.animateToPage(
                    activeIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                return TableById(
                  playerScorecard: viewmodel.game!.sessions[index],
                  updateScoreFieldCommand: viewmodel.updateScoreFieldCommand,
                );
              },
              itemCount: viewmodel.game?.sessions.length,
            ),
          );
        },
      ),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableById extends StatefulWidget {
  final PlayerGameSession _playerGameSession;

  const TableById({
    super.key,
    required PlayerGameSession playerScorecard,
    required Command<(int scorecardId, String fieldName, int? score), void>
    updateScoreFieldCommand,
  }) : _playerGameSession = playerScorecard;

  @override
  State<TableById> createState() => _TableByIdState();
}

class _TableByIdState extends State<TableById> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            const TableCell(child: Center(child: Text(""))),
            InfoTableCell(info: widget._playerGameSession.player.name),
          ],
        ),
        _buildScoreRow(
          'ONES',
          (sc) => sc.ones,
          DatabaseContract.columnScOnes,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'TWOS',
          (sc) => sc.twos,
          DatabaseContract.columnScTwos,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'THREES',
          (sc) => sc.threes,
          DatabaseContract.columnScThrees,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'FOURS',
          (sc) => sc.fours,
          DatabaseContract.columnScFours,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'FIVES',
          (sc) => sc.fives,
          DatabaseContract.columnScFives,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'SIXES',
          (sc) => sc.sixes,
          DatabaseContract.columnScSixes,
          widget._playerGameSession.scorecard,
        ),

        // Upper Bonus etc.
        _buildScoreRow(
          'THREE OF A KIND',
          (sc) => sc.threeOfAKind,
          DatabaseContract.columnScThreeOfAKind,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'FOUR OF A KIND',
          (sc) => sc.fourOfAKind,
          DatabaseContract.columnScFourOfAKind,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'FULL HOUSE',
          (sc) => sc.fullHouse,
          DatabaseContract.columnScFullHouse,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'SMALL STRAIGHT',
          (sc) => sc.smallStraight,
          DatabaseContract.columnScSmallStraight,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'LARGE STRAIGHT',
          (sc) => sc.largeStraight,
          DatabaseContract.columnScLargeStraight,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'YAHTZEE',
          (sc) => sc.yahtzee,
          DatabaseContract.columnScYahtzee,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          'CHANCE',
          (sc) => sc.chance,
          DatabaseContract.columnScChance,
          widget._playerGameSession.scorecard,
        ),
      ],
    );
  }

  TableRow _buildScoreRow(
    String title,
    int? Function(Scorecard) getScore,
    String fieldName,
    Scorecard scorecard,
  ) {
    final score = getScore(scorecard);
    return TableRow(
      children: [
        InfoTableCell(info: title),
        ScoreFieldCell(
          context: context,
          value: score != null ? '$score' : '_',
          scorecardId: scorecard.id as int,
          fieldName: fieldName,
        ),
      ],
    );
  }
}

class ScoreFieldCell extends StatelessWidget {
  const ScoreFieldCell({
    super.key,
    required this.context,
    required this.value,
    required this.scorecardId,
    required this.fieldName,
  });

  final BuildContext context;
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
            builder: (BuildContext dialogContext) => InputDialog(
              context: dialogContext,
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

class InfoTableCell extends StatelessWidget {
  const InfoTableCell({super.key, required this.info, this.bold = true});

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

class InputDialog extends StatefulWidget {
  const InputDialog({
    super.key,
    required this.context,
    required this.viewmodel,
    required this.scorecardId,
    required this.databaseFieldName,
  });

  final BuildContext context;
  final YahtzeeViewmodel viewmodel;
  final int scorecardId;
  final String databaseFieldName;

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final updateScoreFieldCommand = widget.viewmodel.updateScoreFieldCommand;
    return AlertDialog(
      title: const Text('input score'),
      content: TextField(
        controller: _textFieldController,
        decoration: const InputDecoration(hintText: 'score'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(_textFieldController.text);
            if (value == null) return;
            updateScoreFieldCommand.run((
              widget.scorecardId,
              widget.databaseFieldName,
              value,
            ));
            if (mounted) {
              _textFieldController.clear();
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
