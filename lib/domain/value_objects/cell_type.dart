enum CellType {
  empty,
  robot,
  princess,
  flower,
  obstacle;

  String get displayName {
    switch (this) {
      case CellType.empty:
        return 'Empty';
      case CellType.robot:
        return 'Robot';
      case CellType.princess:
        return 'Princess';
      case CellType.flower:
        return 'Flower';
      case CellType.obstacle:
        return 'Obstacle';
    }
  }

  String get icon {
    switch (this) {
      case CellType.empty:
        return '⬜';
      case CellType.robot:
        return '🤖';
      case CellType.princess:
        return '👑';
      case CellType.flower:
        return '🌸';
      case CellType.obstacle:
        return '🗑️';
    }
  }
}
