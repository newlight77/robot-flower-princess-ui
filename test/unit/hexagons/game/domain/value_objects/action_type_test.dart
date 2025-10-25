import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';

void main() {
  group('ActionType Value Object', () {
    test('should have all action types', () {
      expect(ActionType.values.length, 6);
      expect(ActionType.values, contains(ActionType.rotate));
      expect(ActionType.values, contains(ActionType.move));
      expect(ActionType.values, contains(ActionType.pickFlower));
      expect(ActionType.values, contains(ActionType.dropFlower));
      expect(ActionType.values, contains(ActionType.giveFlower));
      expect(ActionType.values, contains(ActionType.clean));
    });

    test('should return correct display name for rotate', () {
      expect(ActionType.rotate.displayName, '↩️ Rotate');
    });

    test('should return correct display name for move', () {
      expect(ActionType.move.displayName, '🚶 Move');
    });

    test('should return correct display name for pickFlower', () {
      expect(ActionType.pickFlower.displayName, '⛏️ Pick Flower');
    });

    test('should return correct display name for dropFlower', () {
      expect(ActionType.dropFlower.displayName, '🫳 Drop Flower');
    });

    test('should return correct display name for giveFlower', () {
      expect(ActionType.giveFlower.displayName, '🫴 Give Flower');
    });

    test('should return correct display name for clean', () {
      expect(ActionType.clean.displayName, '🗑️ Clean');
    });

    test('should return correct icon for rotate', () {
      expect(ActionType.rotate.icon, '↩️');
    });

    test('should return correct icon for move', () {
      expect(ActionType.move.icon, '🚶');
    });

    test('should return correct icon for pickFlower', () {
      expect(ActionType.pickFlower.icon, '⛏️');
    });

    test('should return correct icon for dropFlower', () {
      expect(ActionType.dropFlower.icon, '🫳');
    });

    test('should return correct icon for giveFlower', () {
      expect(ActionType.giveFlower.icon, '🫴');
    });

    test('should return correct icon for clean', () {
      expect(ActionType.clean.icon, '🗑️');
    });

    test('should handle name property correctly', () {
      expect(ActionType.rotate.name, 'rotate');
      expect(ActionType.move.name, 'move');
      expect(ActionType.pickFlower.name, 'pickFlower');
      expect(ActionType.dropFlower.name, 'dropFlower');
      expect(ActionType.giveFlower.name, 'giveFlower');
      expect(ActionType.clean.name, 'clean');
    });

    test('should support lookup by name', () {
      expect(
        ActionType.values.firstWhere((e) => e.name == 'rotate'),
        ActionType.rotate,
      );
      expect(
        ActionType.values.firstWhere((e) => e.name == 'pickFlower'),
        ActionType.pickFlower,
      );
    });

    test('all action types should have unique display names', () {
      final displayNames = ActionType.values.map((e) => e.displayName).toSet();
      expect(displayNames.length, ActionType.values.length);
    });

    test('all action types should have unique icons', () {
      final icons = ActionType.values.map((e) => e.icon).toSet();
      expect(icons.length, ActionType.values.length);
    });
  });
}
