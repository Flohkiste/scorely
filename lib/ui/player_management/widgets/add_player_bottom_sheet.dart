import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/ui/player_management/viewmodel/add_player_viewmodel.dart';

class AddPlayerBottomSheet extends StatefulWidget {
  const AddPlayerBottomSheet({super.key});

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet> {
  late final AddPlayerViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = AddPlayerViewmodel(
      playerRepository: context.read<PlayerRepository>(),
    );

    _viewmodel.addPlayerCommand.results.addListener(_onCommandResult);
  }

  void _onCommandResult() {
    final result = _viewmodel.addPlayerCommand.results.value;

    if (result.hasData && result.data != null && mounted) {
      Navigator.pop(context, result.data);
    }
  }

  @override
  void dispose() {
    _viewmodel.addPlayerCommand.results.removeListener(_onCommandResult);
    _viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddPlayerViewmodel>.value(
      value: _viewmodel,
      child: Consumer<AddPlayerViewmodel>(
        builder: (context, viewmodel, child) {
          final commandError = viewmodel.addPlayerCommand.errors.value?.error;
          final errorMessage = commandError?.toString().replaceAll(
            'Exception: ',
            '',
          );
          final isRunning = viewmodel.addPlayerCommand.isRunning.value;

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: viewmodel.nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Enter Player Name',
                            errorText: errorMessage,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: isRunning
                              ? null
                              : () {
                                  // Command einfach anstoßen (void)
                                  viewmodel.addPlayerCommand.run();
                                },
                          child: isRunning
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Save"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      color: color.primary,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: color.onPrimary,
            ),
            Text(
              "Create Player",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
