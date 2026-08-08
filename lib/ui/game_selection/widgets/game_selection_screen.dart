import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scorely/routing/routes.dart';
import 'package:scorely/ui/game_selection/viewmodel/game_selection_viewmodel.dart';
import 'package:scorely/ui/game_selection/widgets/player_selection_widget.dart';
import 'package:scorely/utils/result.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key, required this.viewModel});

  final GameSelectionViewmodel viewModel;

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    // ListenableBuilder sorgt dafür, dass die UI bei notifyListeners() neu baut
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isLoading = widget.viewModel.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scorely'),
            actions: <Widget>[
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ],
          ),
          body: const SingleChildScrollView(
            child: Column(
              children: <Widget>[PlayerSelectionWidget(), Text('Game History')],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isLoading ? null : _onStartGamePressed,
            tooltip: 'Spiel Starten',
            label: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Spiel Starten'),
          ),
        );
      },
    );
  }

  Future<void> _onStartGamePressed() async {
    final result = await widget.viewModel.startGame();

    if (!mounted) return;

    switch (result) {
      case Ok(value: final gameId):
        context.push(Routes.scoreTracking, extra: gameId);
      case Error(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }
}
