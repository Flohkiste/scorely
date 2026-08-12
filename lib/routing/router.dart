import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/ui/game_selection/widgets/game_selection_screen.dart';
import 'package:scorely/ui/game_selection/viewmodel/game_selection_viewmodel.dart';
import 'package:scorely/ui/player_management/viewmodel/player_management_viewmodel.dart';
import 'package:scorely/ui/player_management/widgets/player_management_screen.dart';
import 'package:scorely/ui/score_tracking/widgets/score_tracking_screen.dart';
import 'package:scorely/ui/score_tracking/viewmodel/score_tracking_viewmodel.dart';
import 'package:scorely/routing/routes.dart';
import 'package:go_router/go_router.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

GoRouter router() => GoRouter(
  observers: [routeObserver],
  initialLocation: Routes.gameSelection,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.gameSelection,
      builder: (context, state) {
        return GameSelectionScreen(
          viewModel: GameSelectionViewmodel(
            playerRepository: context.read<PlayerRepository>(),
            yahtzeeRepository: context.read<YahtzeeRepository>(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.scoreTracking,
      builder: (context, state) {
        final gameId = state.extra as int;
        return ScoreTrackingScreen(
          gameId: gameId,
          viewModel: ScoreTrackingViewmodel(),
        );
      },
    ),
    GoRoute(
      path: Routes.playerManagement,
      builder: (context, state) {
        return PlayerManagementScreen(
          viewmodel: PlayerManagementViewmodel(
            playerRepository: context.read<PlayerRepository>(),
          ),
        );
      },
    ),
  ],
);
