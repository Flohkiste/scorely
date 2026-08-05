import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scorely/data/repositories/game_repository.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/data/services/database_service.dart';
import 'package:scorely/data/services/game_dao.dart';
import 'package:scorely/data/services/player_dao.dart';
import 'package:scorely/data/services/scorecard_dao.dart';

List<SingleChildWidget> get providers {
  return [
    // Database
    Provider.value(value: DatabaseService.instance),

    // DAOs
    Provider(
      create: (context) =>
          PlayerDao(dbService: context.read<DatabaseService>()),
    ),
    Provider(
      create: (context) => GameDao(dbService: context.read<DatabaseService>()),
    ),
    Provider(
      create: (context) =>
          ScorecardDao(dbService: context.read<DatabaseService>()),
    ),

    // Repositorys
    Provider(
      create: (context) =>
          PlayerRepository(playerDao: context.read<PlayerDao>()),
    ),
    Provider(
      create: (context) => GameRepository(
        playerDao: context.read<PlayerDao>(),
        gameDao: context.read<GameDao>(),
        scorecardDao: context.read<ScorecardDao>(),
      ),
    ),
  ];
}
