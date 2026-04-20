import 'package:flutter/material.dart';
import 'package:flutter_logcat/flutter_logcat.dart';
import 'package:provider/provider.dart';
import 'package:scorely/core/color.dart' as color;
import 'package:scorely/features/game_selection/view/game_selection_screen.dart';
import 'package:scorely/features/game_selection/viewmodel/player_management_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Log.configure(visible: true, time: true);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerManagementViewModel()),
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
      theme: color.appThemeData,
      home: GameSelectionScreen(),
    );
  }
}
