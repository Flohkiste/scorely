import 'package:flutter/foundation.dart';
import 'package:scorely/data/repositories/game_repository.dart';
import 'package:scorely/ui/score_tracking/viewmodel/game_viewmodel.dart';

class YahtzeeViewmodel extends ChangeNotifier {
  final GameRepository gameRepository;

  YahtzeeViewmodel({required this.gameRepository});
}
