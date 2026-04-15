import 'package:flutter/material.dart';
import 'package:scorely/features/game_selection/widgets/player_selection_widget.dart';

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
        onPressed: () {},
        tooltip: 'Spiel Starten',
        label: Text('Spiel Starten'),
      ),
    );
  }
}
