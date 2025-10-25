enum ActionType {
  rotate,
  move,
  pickFlower,
  dropFlower,
  giveFlower,
  clean;

  String get displayName {
    switch (this) {
      case ActionType.rotate:
        return '↩️ Rotate';
      case ActionType.move:
        return '🚶 Move';
      case ActionType.pickFlower:
        return '⛏️ Pick Flower';
      case ActionType.dropFlower:
        return '🫳 Drop Flower';
      case ActionType.giveFlower:
        return '🫴 Give Flower';
      case ActionType.clean:
        return '🗑️ Clean';
    }
  }

  String get icon {
    switch (this) {
      case ActionType.rotate:
        return '↩️';
      case ActionType.move:
        return '🚶';
      case ActionType.pickFlower:
        return '⛏️';
      case ActionType.dropFlower:
        return '🫳';
      case ActionType.giveFlower:
        return '🫴';
      case ActionType.clean:
        return '🗑️';
    }
  }
}
