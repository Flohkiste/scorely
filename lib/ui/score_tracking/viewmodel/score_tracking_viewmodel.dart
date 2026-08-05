import 'package:flutter/material.dart';
import 'package:scorely/business/model/player.dart';
import 'package:scorely/data/repositories/player_repository.dart';
import 'package:scorely/utils/result.dart';

class ScoreTrackingViewmodel extends ChangeNotifier {
  final PlayerRepository _playerRepository;

  ScoreTrackingViewmodel({required PlayerRepository playerRepository})
    : _playerRepository = playerRepository;
}
