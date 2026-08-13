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
  final TextEditingController _textFieldController = TextEditingController();
  bool _dialogShown = false;

  @override
  void dispose() {
    _textFieldController.dispose();
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageView.builder(
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
  final Command<(int scorecardId, String fieldName, int? score), void>
  _updateScoreFieldCommand;

  const TableById({
    super.key,
    required PlayerGameSession playerScorecard,
    required Command<(int scorecardId, String fieldName, int? score), void>
    updateScoreFieldCommand,
  }) : _playerGameSession = playerScorecard,
       _updateScoreFieldCommand = updateScoreFieldCommand;

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
            _infoTableCell(widget._playerGameSession.player.name),
          ],
        ),
        _buildScoreRow(
          context,
          'ONES',
          (sc) => sc.ones,
          DatabaseContract.columnScOnes,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'TWOS',
          (sc) => sc.twos,
          DatabaseContract.columnScTwos,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'THREES',
          (sc) => sc.threes,
          DatabaseContract.columnScThrees,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'FOURS',
          (sc) => sc.fours,
          DatabaseContract.columnScFours,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'FIVES',
          (sc) => sc.fives,
          DatabaseContract.columnScFives,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'SIXES',
          (sc) => sc.sixes,
          DatabaseContract.columnScSixes,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),

        // Upper Bonus etc.
        _buildScoreRow(
          context,
          'THREE OF A KIND',
          (sc) => sc.threeOfAKind,
          DatabaseContract.columnScThreeOfAKind,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'FOUR OF A KIND',
          (sc) => sc.fourOfAKind,
          DatabaseContract.columnScFourOfAKind,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'FULL HOUSE',
          (sc) => sc.fullHouse,
          DatabaseContract.columnScFullHouse,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'SMALL STRAIGHT',
          (sc) => sc.smallStraight,
          DatabaseContract.columnScSmallStraight,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'LARGE STRAIGHT',
          (sc) => sc.largeStraight,
          DatabaseContract.columnScLargeStraight,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'YAHTZEE',
          (sc) => sc.yahtzee,
          DatabaseContract.columnScYahtzee,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
        _buildScoreRow(
          context,
          'CHANCE',
          (sc) => sc.chance,
          DatabaseContract.columnScChance,
          widget._updateScoreFieldCommand,
          widget._playerGameSession.scorecard,
        ),
      ],
    );
  }

  Widget _infoTableCell(String info, {bool bold = true}) {
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

  Widget _scoreFieldCell(
    BuildContext context,
    String value,
    Command<(int scorecardId, String databaseFieldName, int? value), void>
    updateScoreFieldCommand,
    int scorecardId,
    String fieldName,
  ) {
    return TableCell(
      child: GestureDetector(
        child: Center(child: Text(value)),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) => _inputDialog(
              dialogContext,
              updateScoreFieldCommand,
              scorecardId,
              fieldName,
            ),
          );
        },
      ),
    );
  }

  TableRow _buildScoreRow(
    BuildContext context,
    String title,
    int? Function(Scorecard) getScore,
    String fieldName,
    Command<(int scorecardId, String databaseFieldName, int? value), void>
    updateScoreFieldCommand,
    Scorecard scorecard,
  ) {
    final score = getScore(scorecard);
    return TableRow(
      children: [
        _infoTableCell(title),
        _scoreFieldCell(
          context,
          score != null ? '$score' : '_',
          updateScoreFieldCommand,
          scorecard.id as int,
          fieldName,
        ),
      ],
    );
  }

  AlertDialog _inputDialog(
    BuildContext context,
    Command<(int scorecardId, String databaseFieldName, int? value), void>
    updateScoreFieldCommand,
    int scorecardId,
    String databaseFieldName,
  ) {
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
              scorecardId,
              databaseFieldName,
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
