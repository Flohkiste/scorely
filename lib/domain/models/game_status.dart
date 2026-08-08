enum GameStatus {
  running('running'),
  completed('completed'),
  paused('paused'),
  cancelled('cancelled');

  final String dbValue;
  const GameStatus(this.dbValue);

  /// Hilfsmethode: Erstellt das Enum aus dem String der Datenbank
  static GameStatus fromDbValue(String value) {
    return GameStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => GameStatus.running,
    );
  }
}
