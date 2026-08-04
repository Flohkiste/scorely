import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/core/color.dart' as color;
import 'package:scorely/core/dependencies.dart';

import 'package:scorely/routing/router.dart';

void main() {
  runApp(MultiProvider(providers: providers, child: const App()));
  //runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final goRouter = router();

    return MaterialApp.router(
      title: 'Scorely',
      theme: color.appThemeData,

      routerConfig: goRouter,
    );
  }
}
