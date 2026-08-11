import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scorely/routing/routes.dart';
import 'package:scorely/ui/player_management/viewmodel/player_management_viewmodel.dart';
import 'package:scorely/ui/player_management/widgets/add_player_bottom_sheet.dart';

class PlayerManagementScreen extends StatefulWidget {
  const PlayerManagementScreen({super.key, required this.viewmodel});

  final PlayerManagementViewmodel viewmodel;

  @override
  State<PlayerManagementScreen> createState() => _PlayerManagementScreenState();
}

class _PlayerManagementScreenState extends State<PlayerManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewmodel.loadPlayersCommand.run();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Players"),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.gameSelection);
            }
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewmodel.loadPlayersCommand,
        builder: (context, _) {
          final command = widget.viewmodel.loadPlayersCommand;

          if (command.isRunning.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fehleranzeige mit Retry-Option
          if (command.errors.value != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fehler beim Laden: ${command.errors.value}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: command.run,
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Active Players',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.viewmodel.activePlayers.map(
                (p) => ListTile(
                  title: Text(p.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.archive_outlined),
                        tooltip: 'Archive',
                        onPressed: () =>
                            widget.viewmodel.archivePlayerCommand.run(p.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () =>
                            widget.viewmodel.deletePlayerCommand.run(p.id),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Archived Players',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.viewmodel.archivedPlayers.map(
                (p) => ListTile(
                  title: Text(p.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.send_and_archive),
                        tooltip: 'Activate',
                        onPressed: () =>
                            widget.viewmodel.activatePlayerCommand.run(p.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () =>
                            widget.viewmodel.deletePlayerCommand.run(p.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPlayerPressed(),
        tooltip: 'Add new player',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _onAddPlayerPressed() async {
    final newPlayer = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddPlayerBottomSheet(),
    );

    if (newPlayer != null) {
      widget.viewmodel.loadPlayersCommand.run();
    }
  }
}
