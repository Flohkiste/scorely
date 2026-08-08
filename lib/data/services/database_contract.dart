abstract class DatabaseContract {
  // Datenbank-Info
  static const String dbName = 'game_tracker.db';
  static const int dbVersion = 1;

  // --- TABELLE: PLAYERS ---
  // player(id, name)
  static const String tablePlayers = 'players';
  static const String columnPlayerId = 'id';
  static const String columnPlayerName = 'name';

  // --- TABELLE: GAMES ---
  // game(id, created_at, status, current_player_id)
  static const String tableGames = 'games';
  static const String columnGameId = 'id';
  static const String columnGameCreatedAt = 'created_at';
  static const String columnGameStatus = 'status';
  static const String columnGameCurrentPlayerId = 'current_player_id';

  // --- TABELLE: GAME_PLAYERS (Junction Table) ---
  // game_player(id, game_id, player_id, player_order, total_score)
  static const String tableGamePlayers = 'game_players';
  static const String columnGpId = 'id';
  static const String columnGpGameId = 'game_id';
  static const String columnGpPlayerId = 'player_id';
  static const String columnGpPlayerOrder = 'player_order';
  static const String columnGpTotalScore = 'total_score';

  // --- TABELLE: SCORECARD-Yahtzee ---
  // scorecard(id, game_player_id, ones, twos, threes, fours, fives, sixes,
  // upper_bonus, three_of_a_kind, four_of_a_kind, full_house, small_straight, large_straight, yahtzee, chance)
  static const String tableScorecards = 'scorecards_yahtzee';
  static const String columnScId = 'id';
  static const String columnScGamePlayerId = 'game_player_id';

  // Oberer Teil
  static const String columnScOnes = 'ones';
  static const String columnScTwos = 'twos';
  static const String columnScThrees = 'threes';
  static const String columnScFours = 'fours';
  static const String columnScFives = 'fives';
  static const String columnScSixes = 'sixes';
  static const String columnScUpperBonus = 'upper_bonus';

  // Unterer Teil
  static const String columnScThreeOfAKind = 'three_of_a_kind';
  static const String columnScFourOfAKind = 'four_of_a_kind';
  static const String columnScFullHouse = 'full_house';
  static const String columnScSmallStraight = 'small_straight';
  static const String columnScLargeStraight = 'large_straight';
  static const String columnScYahtzee = 'yahtzee';
  static const String columnScChance = 'chance';
}
