enum GameStatus {
  playing,
  won,
  gameOver;

  String get displayName {
    switch (this) {
      case GameStatus.playing:
        return '🎮 Playing';
      case GameStatus.won:
        return '🏆 Won';
      case GameStatus.gameOver:
        return '💀 Game Over';
    }
  }

  bool get isFinished => this == GameStatus.won || this == GameStatus.gameOver;
}
