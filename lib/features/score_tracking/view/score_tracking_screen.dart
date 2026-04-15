import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/viewmodel/player_selection_viewmodel.dart';

class ScoreTrackingScreen extends StatelessWidget {
  const ScoreTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = context.read<PlayerSelectionViewmodel>().selectedPlayers;

    return Scaffold(
      appBar: AppBar(title: Text("Game")),
      body: Text("Spieler: $players"),
    );
  }
}
