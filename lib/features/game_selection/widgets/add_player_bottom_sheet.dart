import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/viewmodel/player_selection_viewmodel.dart';

//TODO: Smaller Widgets
//TODO: Beim Erstellen Fehler Anzeigen (Spielername gibts schon...)

class AddPlayerBottomSheet extends StatefulWidget {
  const AddPlayerBottomSheet({super.key});

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerSelectionViewModel = Provider.of<PlayerSelectionViewmodel>(
      context,
    );

    final color = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: color.primary,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
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
            ),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Player Name',
              ),
            ),
            FilledButton(
              onPressed: () {
                if (myController.text.isNotEmpty &&
                    !playerSelectionViewModel.players.contains(
                      myController.text,
                    )) {
                  playerSelectionViewModel.addPlayer(myController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
