class AppConstants {
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const Duration apiTimeout = Duration(seconds: 30);

  // Game Configuration
  static const int minBoardSize = 3;
  static const int maxBoardSize = 50;
  static const int defaultBoardSize = 10;
  static const int maxFlowers = 12;
  static const double maxFlowerPercentage = 0.10;
  static const double obstaclePercentage = 0.30;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration replayStepDuration = Duration(milliseconds: 800);

  // Storage Keys
  static const String gamesListKey = 'games_list';
  static const String currentGameKey = 'current_game';
}
