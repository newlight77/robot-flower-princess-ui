enum Direction {
  north,
  east,
  south,
  west;

  String get displayName {
    switch (this) {
      case Direction.north:
        return '⬆️ North';
      case Direction.east:
        return '➡️ East';
      case Direction.south:
        return '⬇️ South';
      case Direction.west:
        return '⬅️ West';
    }
  }

  String get icon {
    switch (this) {
      case Direction.north:
        return '⬆️';
      case Direction.east:
        return '➡️';
      case Direction.south:
        return '⬇️';
      case Direction.west:
        return '⬅️';
    }
  }
}
