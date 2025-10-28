enum Direction {
  NORTH,
  EAST,
  SOUTH,
  WEST;

  String get displayName {
    switch (this) {
      case Direction.NORTH:
        return '⬆️ North';
      case Direction.EAST:
        return '➡️ East';
      case Direction.SOUTH:
        return '⬇️ South';
      case Direction.WEST:
        return '⬅️ West';
    }
  }

  String get icon {
    switch (this) {
      case Direction.NORTH:
        return '⬆️';
      case Direction.EAST:
        return '➡️';
      case Direction.SOUTH:
        return '⬇️';
      case Direction.WEST:
        return '⬅️';
    }
  }
}
