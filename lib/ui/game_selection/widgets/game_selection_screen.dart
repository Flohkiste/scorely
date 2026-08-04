import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scorely/ui/game_selection/viewmodel/game_selection_viewmodel.dart';
import 'package:scorely/ui/game_selection/widgets/player_selection_widget.dart';

import 'package:scorely/routing/routes.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key, required this.viewModel});

  final GameSelectionViewmodel viewModel;

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
          PlayerSelectionWidget(),
          Text('Game History'), //TODO: GameHistory() Widget / Screen
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.scoreTracking);
        },
        tooltip: 'Spiel Starten',
        label: Text('Spiel Starten'),
      ),
    );
  }
}
