import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/cell_type.dart';

void main() {
  group('CellType Value Object', () {
    test('should have all cell types', () {
      expect(CellType.values.length, 5);
      expect(CellType.values, contains(CellType.empty));
      expect(CellType.values, contains(CellType.robot));
      expect(CellType.values, contains(CellType.princess));
      expect(CellType.values, contains(CellType.flower));
      expect(CellType.values, contains(CellType.obstacle));
    });

    test('should return correct display name for empty', () {
      expect(CellType.empty.displayName, 'Empty');
    });

    test('should return correct display name for robot', () {
      expect(CellType.robot.displayName, 'Robot');
    });

    test('should return correct display name for princess', () {
      expect(CellType.princess.displayName, 'Princess');
    });

    test('should return correct display name for flower', () {
      expect(CellType.flower.displayName, 'Flower');
    });

    test('should return correct display name for obstacle', () {
      expect(CellType.obstacle.displayName, 'Obstacle');
    });

    test('should return correct icon for empty', () {
      expect(CellType.empty.icon, '⬜');
    });

    test('should return correct icon for robot', () {
      expect(CellType.robot.icon, '🤖');
    });

    test('should return correct icon for princess', () {
      expect(CellType.princess.icon, '👑');
    });

    test('should return correct icon for flower', () {
      expect(CellType.flower.icon, '🌸');
    });

    test('should return correct icon for obstacle', () {
      expect(CellType.obstacle.icon, '🗑️');
    });

    test('should handle name property correctly', () {
      expect(CellType.empty.name, 'empty');
      expect(CellType.robot.name, 'robot');
      expect(CellType.princess.name, 'princess');
      expect(CellType.flower.name, 'flower');
      expect(CellType.obstacle.name, 'obstacle');
    });

    test('should support lookup by name', () {
      expect(
        CellType.values.firstWhere((e) => e.name == 'empty'),
        CellType.empty,
      );
      expect(
        CellType.values.firstWhere((e) => e.name == 'flower'),
        CellType.flower,
      );
    });

    test('all cell types should have unique display names', () {
      final displayNames = CellType.values.map((e) => e.displayName).toSet();
      expect(displayNames.length, CellType.values.length);
    });

    test('all cell types should have unique icons', () {
      final icons = CellType.values.map((e) => e.icon).toSet();
      expect(icons.length, CellType.values.length);
    });

    test('should be comparable', () {
      const type1 = CellType.flower;
      const type2 = CellType.flower;
      const type3 = CellType.obstacle;

      expect(type1 == type2, true);
      expect(type1 == type3, false);
    });
  });
}
