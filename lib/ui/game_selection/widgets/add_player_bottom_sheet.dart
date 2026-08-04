import 'package:flutter/material.dart';
import 'package:flutter_logcat/flutter_logcat.dart';
import 'package:scorely/ui/game_selection/viewmodel/player_selection_viewmodel.dart';
import 'package:scorely/utils/result.dart';

//TODO: Smaller Widgets
//TODO: Beim Erstellen Fehler Anzeigen (Spielername gibts schon...)

class AddPlayerBottomSheet extends StatefulWidget {
  const AddPlayerBottomSheet({super.key, required this.viewmodel});

  final PlayerSelectionViewmodel viewmodel;

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
              onPressed: () async {
                final result = await widget.viewmodel.addPlayer(
                  myController.text,
                );

                if (!context.mounted) return;

                switch (result) {
                  case Ok():
                    Navigator.pop(context);
                  case Error(error: final e):
                    setState(() {
                      error = e.toString();
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
