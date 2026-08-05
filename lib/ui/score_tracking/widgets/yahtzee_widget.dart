import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/ui/score_tracking/viewmodel/yahtzee_viewmodel.dart';

class YahtzeeWidget extends StatefulWidget {
  const YahtzeeWidget({super.key});

  @override
  State<YahtzeeWidget> createState() => _YahtzeeWidgetState();
}

class _YahtzeeWidgetState extends State<YahtzeeWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YahtzeeViewmodel>(
      create: (context) =>
          YahtzeeViewmodel(playerRepository: context.read<PlayerRepository>())
            ..loadPlayers(),
      child: Consumer<YahtzeeViewmodel>(
        builder: (context, viewmodel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Players: ${viewmodel.selectedPlayers.map((p) => p.name).join(', ')}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }
}
