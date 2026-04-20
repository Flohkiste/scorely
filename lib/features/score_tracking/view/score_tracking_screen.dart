import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/viewmodel/player_management_viewmodel.dart';

class ScoreTrackingScreen extends StatelessWidget {
  const ScoreTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = context.read<PlayerManagementViewModel>().selectedPlayers;

    return Scaffold(
      appBar: AppBar(title: Text("Game")),
      body: Text("Spieler: $players"),
    );
  }
}
