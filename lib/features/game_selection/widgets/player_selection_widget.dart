import 'package:flutter/material.dart';
import 'package:scorely/features/game_selection/viewmodel/player_selection_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/widgets/add_player_bottom_sheet.dart';

class PlayerSelectionWidget extends StatelessWidget {
  const PlayerSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final playerSelectionViewModel = Provider.of<PlayerSelectionViewmodel>(
      context,
    );

    return Column(
      children: [
        const _Header(),

        Wrap(
          spacing: 8,
          children: [
            _AddPlayerButton(),
            ...playerSelectionViewModel.players.map((player) {
              return _PlayerSelectionButton(
                playerName: player,
                isSelected: playerSelectionViewModel.isSelected(player),
                onPressed: () =>
                    playerSelectionViewModel.toggleSelectPlayer(player),
                onLongPressed: () =>
                    playerSelectionViewModel.deletePlayer(player),
              );
            }),
          ],
        ),
      ],
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
  const _AddPlayerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color.secondary),
      ),
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => AddPlayerBottomSheet(),
      ),
      child: const Text("Add"),
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
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isSelected ? color.primary : color.surface,
        ),
        foregroundColor: WidgetStateProperty.all(
          isSelected ? color.onPrimary : color.onSurface,
        ),

        side: WidgetStateProperty.all(BorderSide(color: color.primary)),
      ),
      onPressed: onPressed,
      onLongPress: onLongPressed,
      child: Text(playerName),
    );
  }
}
