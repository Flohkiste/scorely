abstract class DatabaseContract {
  // Datenbank-Info
  static const String dbName = 'game_tracker.db';
  static const int dbVersion = 1;

  // --- TABELLE: PLAYERS ---
  static const String tablePlayers = 'players';
  static const String columnPlayerId = 'id';
  static const String columnPlayerName = 'name';

  // --- TABELLE: GAMES ---
  static const String tableGames = 'games';
  static const String columnGameId = 'id';
  static const String columnCreatedAt = 'created_at';

  // --- TABELLE: GAME_PLAYERS (Junction Table) ---
  static const String tableGamePlayers = 'game_players';
  static const String columnGpGameId = 'game_id';
  static const String columnGpPlayerId = 'player_id';
  static const String columnGpScore = 'score';
}
