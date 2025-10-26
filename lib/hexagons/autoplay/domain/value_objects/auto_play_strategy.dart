/// Strategy for AI-powered auto-play
enum AutoPlayStrategy {
  /// Greedy strategy: Safe & reliable.
  /// 75% success rate. Checks safety before picking flowers.
  greedy,

  /// Optimal strategy: Fast & efficient.
  /// 62% success rate, but 25% fewer actions.
  /// Uses A* pathfinding and multi-step planning.
  optimal,

  /// ML strategy: Hybrid ML/heuristic approach.
  /// Uses ML Player service for predictions. Learns from game patterns.
  ml;

  /// Converts the strategy to API query parameter format
  String toApiParam() => name;

  /// Creates strategy from API string
  static AutoPlayStrategy fromString(String value) {
    return AutoPlayStrategy.values.firstWhere(
      (strategy) => strategy.name == value.toLowerCase(),
      orElse: () => AutoPlayStrategy.greedy,
    );
  }

  /// Returns a human-readable description
  String get description {
    switch (this) {
      case AutoPlayStrategy.greedy:
        return 'Safe & reliable (75% success rate)';
      case AutoPlayStrategy.optimal:
        return 'Fast & efficient (62% success, -25% actions)';
      case AutoPlayStrategy.ml:
        return 'Hybrid ML/heuristic - Learns from patterns';
    }
  }

  /// Returns success rate percentage
  int get successRate {
    switch (this) {
      case AutoPlayStrategy.greedy:
        return 75;
      case AutoPlayStrategy.optimal:
        return 62;
      case AutoPlayStrategy.ml:
        return 85; // Assuming ML has better performance
    }
  }
}
