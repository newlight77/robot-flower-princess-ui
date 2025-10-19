import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

void main() {
  group('Robot Entity', () {
    test('should create robot with valid parameters', () {
      const robot = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      expect(robot.position.x, 0);
      expect(robot.position.y, 0);
      expect(robot.orientation, Direction.north);
      expect(robot.flowersHeld, 0);
    });

    test('should check if robot has flowers', () {
      const robotWithFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robotWithoutFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      expect(robotWithFlowers.hasFlowers, true);
      expect(robotWithoutFlowers.hasFlowers, false);
    });

    test('should check if robot can pick more flowers', () {
      const robotCanPick = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robotFull = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 12,
      );

      expect(robotCanPick.canPickMore, true);
      expect(robotFull.canPickMore, false);
    });

    test('should create copy with updated fields', () {
      const original = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      final updated = original.copyWith(
        position: const Position(x: 1, y: 1),
        flowersHeld: 3,
      );

      expect(updated.position.x, 1);
      expect(updated.position.y, 1);
      expect(updated.flowersHeld, 3);
      expect(updated.orientation, Direction.north);
    });

    test('should serialize to JSON', () {
      const robot = Robot(
        position: Position(x: 2, y: 3),
        orientation: Direction.east,
        flowersHeld: 4,
      );

      final json = robot.toJson();

      expect(json['position']['x'], 2);
      expect(json['position']['y'], 3);
      expect(json['orientation'], 'east');
      expect(json['flowersHeld'], 4);
    });

    test('should deserialize from JSON', () {
      final json = {
        'position': {'x': 2, 'y': 3},
        'orientation': 'south',
        'flowersHeld': 7,
      };

      final robot = Robot.fromJson(json);

      expect(robot.position.x, 2);
      expect(robot.position.y, 3);
      expect(robot.orientation, Direction.south);
      expect(robot.flowersHeld, 7);
    });

    test('should maintain equality for same values', () {
      const robot1 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robot2 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      expect(robot1, robot2);
    });
  });
}
