import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/data/services/database_service.dart';
import 'package:scorely/data/services/player_dao.dart';

List<SingleChildWidget> get providers {
  return [
    Provider.value(value: DatabaseService.instance),
    Provider(
      create: (context) =>
          PlayerDao(dbService: context.read<DatabaseService>()),
    ),
    Provider(
      create: (context) =>
          PlayerRepository(playerDao: context.read<PlayerDao>()),
    ),
  ];
}
