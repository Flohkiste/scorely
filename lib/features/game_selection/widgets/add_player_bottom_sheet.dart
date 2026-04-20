import 'package:flutter/material.dart';
import 'package:flutter_logcat/flutter_logcat.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/viewmodel/player_management_viewmodel.dart';

//TODO: Smaller Widgets
//TODO: Beim Erstellen Fehler Anzeigen (Spielername gibts schon...)

class AddPlayerBottomSheet extends StatefulWidget {
  const AddPlayerBottomSheet({super.key});

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet> {
  final myController = TextEditingController();
  String error = "";

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerManagementViewModel = Provider.of<PlayerManagementViewModel>(
      context,
      listen: false,
    );

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Header(),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Player Name',
                errorText: error.isNotEmpty ? error : null,
              ),
            ),
            FilledButton(
              onPressed: () {
                final result = playerManagementViewModel.addPlayer(
                  myController.text,
                );

                if (result == AddPlayerResult.success) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    error = result.toString();
                  });
                  Log.e(error);
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

class _Header extends StatelessWidget {
  const _Header({super.key});

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
    );
  }
}
