import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/data/services/database_contract.dart';
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
      create: (context) => YahtzeeViewmodel(
        gameId: widget.gameId,
        yahtzeeRepository: context.read<YahtzeeRepository>(),
      )..loadGame(),
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
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    const TableCell(child: Center(child: Text(""))),

                    ...viewmodel.getPlayers().map((player) {
                      return _infoTableCell(player);
                    }),
                  ],
                ),
                _buildScoreRow(
                  'ONES',
                  (sc) => sc.ones,
                  DatabaseContract.columnScOnes,
                  viewmodel,
                ),
                _buildScoreRow(
                  'TWOS',
                  (sc) => sc.twos,
                  DatabaseContract.columnScTwos,
                  viewmodel,
                ),
                _buildScoreRow(
                  'THREES',
                  (sc) => sc.threes,
                  DatabaseContract.columnScThrees,
                  viewmodel,
                ),
                _buildScoreRow(
                  'FOURS',
                  (sc) => sc.fours,
                  DatabaseContract.columnScFours,
                  viewmodel,
                ),
                _buildScoreRow(
                  'FIVES',
                  (sc) => sc.fives,
                  DatabaseContract.columnScFives,
                  viewmodel,
                ),
                _buildScoreRow(
                  'SIXES',
                  (sc) => sc.sixes,
                  DatabaseContract.columnScSixes,
                  viewmodel,
                ),

                // Upper Bonus etc.
                TableRow(
                  children: [
                    _infoTableCell('Top Total'),
                    ...viewmodel.game!.sessions.map((session) {
                      return _infoTableCell(
                        '-',
                      ); // Später durch sc.topTotal ersetzen
                    }),
                  ],
                ),

                _buildScoreRow(
                  'THREE OF A KIND',
                  (sc) => sc.threeOfAKind,
                  DatabaseContract.columnScThreeOfAKind,
                  viewmodel,
                ),
                _buildScoreRow(
                  'FOUR OF A KIND',
                  (sc) => sc.fourOfAKind,
                  DatabaseContract.columnScFourOfAKind,
                  viewmodel,
                ),
                _buildScoreRow(
                  'FULL HOUSE',
                  (sc) => sc.fullHouse,
                  DatabaseContract.columnScFullHouse,
                  viewmodel,
                ),
                _buildScoreRow(
                  'SMALL STRAIGHT',
                  (sc) => sc.smallStraight,
                  DatabaseContract.columnScSmallStraight,
                  viewmodel,
                ),
                _buildScoreRow(
                  'LARGE STRAIGHT',
                  (sc) => sc.largeStraight,
                  DatabaseContract.columnScLargeStraight,
                  viewmodel,
                ),
                _buildScoreRow(
                  'YAHTZEE',
                  (sc) => sc.yahtzee,
                  DatabaseContract.columnScYahtzee,
                  viewmodel,
                ),
                _buildScoreRow(
                  'CHANCE',
                  (sc) => sc.chance,
                  DatabaseContract.columnScChance,
                  viewmodel,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTableCell(String info) {
    return TableCell(
      child: Center(
        child: Text(info, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _scoreFieldCell(
    String value,
    YahtzeeViewmodel viewModel,
    int scorecardId,
    String fieldName,
  ) {
    return TableCell(
      child: GestureDetector(
        child: Center(child: Text(value)),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _inputDialog(context, viewModel, scorecardId, fieldName),
          );
        },
      ),
    );
  }

  TableRow _buildScoreRow(
    String title,
    int? Function(Scorecard) getScore,
    String fieldName,
    YahtzeeViewmodel viewmodel,
  ) {
    return TableRow(
      children: [
        _infoTableCell(title),
        ...viewmodel.game!.sessions.map((session) {
          final score = getScore(session.scorecard);
          return _scoreFieldCell(
            score != null ? '$score' : '_',
            viewmodel,
            session.scorecard.id!,
            fieldName,
          );
        }),
      ],
    );
  }

  AlertDialog _inputDialog(
    BuildContext context,
    YahtzeeViewmodel viewModel,
    int scorecardId,
    String fieldName,
  ) {
    _textFieldController.clear();
    return AlertDialog(
      title: const Text('input score'),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(hintText: 'score'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            final value = int.tryParse(_textFieldController.text);
            if (value == null) return;
            await viewModel.updateScoreField(scorecardId, fieldName, value);
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: Text('OK'),
        ),
      ],
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
