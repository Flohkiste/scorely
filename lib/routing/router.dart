import 'package:scorely/features/game_selection/view/game_selection_screen.dart';
import 'package:scorely/features/game_selection/viewmodel/game_selection_viewmodel.dart';
import 'package:scorely/features/score_tracking/view/score_tracking_screen.dart';
import 'package:scorely/features/score_tracking/viewmodel/score_tracking_viewmodel.dart';
import 'package:scorely/routing/routes.dart';
import 'package:go_router/go_router.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.gameSelection,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.gameSelection,
      builder: (context, state) {
        return GameSelectionScreen(viewModel: GameSelectionViewmodel());
      },
    ),
    GoRoute(
      path: Routes.scoreTracking,
      builder: (context, state) {
        return ScoreTrackingScreen(viewModel: ScoreTrackingViewmodel());
      },
    ),
  ],
);
