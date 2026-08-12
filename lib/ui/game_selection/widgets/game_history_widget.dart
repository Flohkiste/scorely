import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/domain/models/game_summary.dart';
import 'package:scorely/routing/router.dart';
import 'package:scorely/ui/game_selection/viewmodel/game_history_viewmodel.dart';

class GameHistoryWidget extends StatefulWidget {
  const GameHistoryWidget({super.key});

  @override
  State<GameHistoryWidget> createState() => _GameHistoryWidgetState();
}

class _GameHistoryWidgetState extends State<GameHistoryWidget> with RouteAware {
  late final GameHistoryViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = GameHistoryViewmodel(
      yahtzeeRepository: context.read<YahtzeeRepository>(),
    )..loadHistoryCommand.run();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _viewmodel.dispose(); // ViewModel sauber aufräumen
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      _viewmodel.loadHistoryCommand.run();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewmodel,
      child: Consumer<GameHistoryViewmodel>(
        builder: (context, viewmodel, child) {
          if (viewmodel.loadHistoryCommand.isRunning == true &&
              viewmodel.gameSummarys.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewmodel.gameSummarys.isEmpty) {
            return Column(
              children: [
                _Header(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Noch keine beendeten Spiele vorhanden.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              spacing: 0,
              children: [
                _Header(),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...viewmodel.gameSummarys.map((game) {
                      return GameSummaryCard(summary: game);
                    }),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 8, 4),
      child: Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            spacing: 8.0,
            children: [
              Icon(Icons.history, size: 25),
              Text(
                'History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameSummaryCard extends StatelessWidget {
  final GameSummary summary;
  final VoidCallback? onTap;

  const GameSummaryCard({super.key, required this.summary, this.onTap});

  static const _rankColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silber
    Color(0xFFCD7F32), // Bronze
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(summary.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${summary.totalPlayers} Spieler',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (summary.topThreePlayers.isNotEmpty)
                Column(
                  children: List.generate(summary.topThreePlayers.length, (
                    index,
                  ) {
                    final player = summary.topThreePlayers[index];
                    final isWinner = index == 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: isWinner ? 20 : 16,
                            color: _rankColors[index],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: isWinner
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: isWinner ? 15 : 14,
                                color: isWinner
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${player.score} Pkt',
                            style: TextStyle(
                              fontWeight: isWinner
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: isWinner ? 15 : 14,
                              color: isWinner
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.${dt.year} • $hour:$minute Uhr';
  }
}
