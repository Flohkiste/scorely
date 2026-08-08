import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scorely/data/daos/yahtzee_dao.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/data/repositories/yahtzee_repository.dart';
import 'package:scorely/data/services/database_service.dart';
import 'package:scorely/data/daos/player_dao.dart';

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
      create: (context) =>
          YahtzeeDao(dbService: context.read<DatabaseService>()),
    ),

    // Repositorys
    Provider(
      create: (context) =>
          PlayerRepository(playerDao: context.read<PlayerDao>()),
    ),
    Provider(
      create: (context) =>
          YahtzeeRepository(yahtzeeDao: context.read<YahtzeeDao>()),
    ),
  ];
}
