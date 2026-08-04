import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/ui/game_selection/viewmodel/player_selection_viewmodel.dart';
import 'package:scorely/ui/game_selection/widgets/add_player_bottom_sheet.dart';

class PlayerSelectionWidget extends StatelessWidget {
  const PlayerSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlayerSelectionViewmodel>(
      create: (context) => PlayerSelectionViewmodel(
        playerRepository: context.read<PlayerRepository>(),
      )..loadPlayers(),
      child: Consumer<PlayerSelectionViewmodel>(
        builder: (context, viewmodel, child) {
          return Column(
            children: [
              const _Header(),

              Wrap(
                spacing: 8,
                children: [
                  _AddPlayerButton(viewmodel: viewmodel),
                  ...viewmodel.players.map((player) {
                    return _PlayerSelectionButton(
                      playerName: player.name,
                      isSelected: viewmodel.isSelected(player.id!),
                      onPressed: () =>
                          viewmodel.togglePlayerSelection(player.id!),
                      onLongPressed: () {
                        viewmodel.deletePlayer(player.id!);
                      }, //viewmodel.deletePlayer(player),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 8, 4),
      child: const Row(
        spacing: 8.0,
        children: [
          Icon(Icons.group),
          Text(
            'Players',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ) /*Icon(Icons.edit)*/,
        ],
      ),
    );
  }
}

class _AddPlayerButton extends StatelessWidget {
  const _AddPlayerButton({super.key, required this.viewmodel});

  final PlayerSelectionViewmodel viewmodel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color.secondary),
      ),
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) =>
            AddPlayerBottomSheet(viewmodel: viewmodel),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.add), const Text(" Create")],
      ),
    );
  }
}

class _PlayerSelectionButton extends StatelessWidget {
  final String playerName;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;

  const _PlayerSelectionButton({
    super.key,
    required this.playerName,
    required this.isSelected,
    required this.onPressed,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? color.primaryContainer : color.surface,
        foregroundColor: isSelected
            ? color.onPrimaryContainer
            : color.onSurface,
        side: BorderSide(color: color.primary),
      ),
      onPressed: onPressed,
      onLongPress: onLongPressed,
      child: Text(playerName),
    );
  }
}
