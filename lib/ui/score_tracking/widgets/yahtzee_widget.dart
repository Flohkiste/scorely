import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/ui/score_tracking/viewmodel/yahtzee_viewmodel.dart';

class YahtzeeWidget extends StatefulWidget {
  const YahtzeeWidget({super.key});

  @override
  State<YahtzeeWidget> createState() => _YahtzeeWidgetState();
}

class _YahtzeeWidgetState extends State<YahtzeeWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YahtzeeViewmodel>(
      create: (context) => YahtzeeViewmodel(),
      child: Consumer<YahtzeeViewmodel>(
        builder: (context, viewmodel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("Yahtzee"))),
                    TableCell(child: Center(child: Text('Player'))),
                    TableCell(child: Center(child: Text('Player'))),
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
