import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/viewmodel/player_selection_viewmodel.dart';
import 'package:scorely/features/game_selection/widgets/player_selection_widget.dart';
import 'package:scorely/features/score_tracking/view/score_tracking_screen.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scorely',
        ), // TODO: DropDownButton zur Spieleauswahl statt App Name
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: <Widget>[
          PlayerSelectionWidget(), //TODO: SelectPlayers() Widget / Screen
          Text('Game History'), //TODO: GameHistory() Widget / Screen
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!context.read<PlayerSelectionViewmodel>().isReadyToStart()) {
            return;
          }

          Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (context) => const ScoreTrackingScreen(),
            ),
          );
        },
        tooltip: 'Spiel Starten',
        label: Text('Spiel Starten'),
      ),
    );
  }
}
