import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/ui/score_tracking/viewmodel/yatzy_viewmodel.dart';

class YatzyWidget extends StatefulWidget {
  const YatzyWidget({super.key});

  @override
  State<YatzyWidget> createState() => _YatzyWidgetState();
}

class _YatzyWidgetState extends State<YatzyWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YatzyViewmodel>(
      create: (context) =>
          YatzyViewmodel(playerRepository: context.read<PlayerRepository>())
            ..loadPlayers(),
      child: Consumer<YatzyViewmodel>(
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
