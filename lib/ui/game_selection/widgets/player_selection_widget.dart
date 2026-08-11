import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/domain/models/player.dart';
import 'package:scorely/routing/routes.dart';
import 'package:scorely/ui/game_selection/viewmodel/player_selection_viewmodel.dart';
import 'package:scorely/ui/player_management/widgets/add_player_bottom_sheet.dart';

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
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              spacing: 0,
              children: [
                _Header(
                  onPressed: () async {
                    await context.push(Routes.playerManagement);

                    if (context.mounted) {
                      viewmodel.loadPlayers();
                    }
                  },
                ),

                Wrap(
                  spacing: 4,
                  alignment: WrapAlignment.center,
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
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onPressed;
  const _Header({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 8, 4),
      child: Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            spacing: 8.0,
            children: [
              Icon(Icons.group, size: 25),
              Text(
                'Players',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          IconButton(
            icon: Icon(Icons.edit),
            iconSize: 23,
            onPressed: () {
              onPressed();
            },
          ),
        ],
      ),
    );
  }
}

class _AddPlayerButton extends StatelessWidget {
  const _AddPlayerButton({required this.viewmodel});

  final PlayerSelectionViewmodel viewmodel;

  Future<void> _onAddPlayerPressed(BuildContext context) async {
    // Öffnet das Sheet und wartet auf das Rückgabe-Objekt (Player)
    final newPlayer = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true, // Wichtig für die Tastatur
      builder: (context) => const AddPlayerBottomSheet(),
    );

    // Wenn ein Spieler erfolgreich erstellt wurde:
    if (newPlayer != null && context.mounted) {
      // 1. Spielerliste neu laden
      await viewmodel.loadPlayers();

      if (newPlayer.id != null && !viewmodel.isSelected(newPlayer.id!)) {
        viewmodel.togglePlayerSelection(newPlayer.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => _onAddPlayerPressed(context),
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
