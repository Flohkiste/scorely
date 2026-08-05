import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scorely/ui/score_tracking/viewmodel/score_tracking_viewmodel.dart';
import 'package:scorely/routing/routes.dart';
import 'package:scorely/ui/score_tracking/widgets/yatzy_widget.dart';

class ScoreTrackingScreen extends StatelessWidget {
  const ScoreTrackingScreen({super.key, required this.viewModel});

  final ScoreTrackingViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game"),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.gameSelection);
            }
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return YatzyWidget();
        },
      ),
    );
  }
}
