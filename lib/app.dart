import 'package:flutter/material.dart';
import 'package:flutter_logcat/flutter_logcat.dart';
import 'package:provider/provider.dart';
import 'package:scorely/features/game_selection/view/game_selection_screen.dart';
import 'package:scorely/features/game_selection/viewmodel/player_selection_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Log.configure(visible: true, time: true);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerSelectionViewmodel()),
      ],
      child: Material(),
    );
    //return Material();
  }
}

class Material extends StatelessWidget {
  const Material({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scorely',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
          contrastLevel: 0.0,
        ),
      ),
      home: GameSelectionScreen(),
    );
  }
}
