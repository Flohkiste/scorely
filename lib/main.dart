import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/config/dependencies.dart';

import 'package:scorely/routing/router.dart';
import 'package:scorely/ui/core/themes/theme.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}
