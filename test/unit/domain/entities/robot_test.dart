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
      );

      expect(robot.position.x, 0);
      expect(robot.position.y, 0);
      expect(robot.orientation, Direction.north);
      expect(robot.flowersHeld, 0);
    });

    test('should check if robot has flowers', () {
      final robotWithFlowers = Robot(
        position: const Position(x: 0, y: 0),
        orientation: Direction.north,
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: const [Position(x: 1, y: 1)],
      );

      const robotWithoutFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
      );

      expect(robotWithFlowers.hasFlowers, true);
      expect(robotWithoutFlowers.hasFlowers, false);
    });

    test('should check if robot can pick more flowers', () {
      final robotCanPick = Robot(
        position: const Position(x: 0, y: 0),
        orientation: Direction.north,
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: const [Position(x: 1, y: 1)],
      );

      final robotFull = Robot(
        position: const Position(x: 0, y: 0),
        orientation: Direction.north,
        collectedFlowers: List.generate(12, (i) => Position(x: i, y: 0)),
      );

      expect(robotCanPick.canPickMore, true);
      expect(robotFull.canPickMore, false);
    });

    test('should create copy with updated fields', () {
      const original = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
      );

      final updated = original.copyWith(
        position: const Position(x: 1, y: 1),
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
      );

      expect(updated.position.x, 1);
      expect(updated.position.y, 1);
      expect(updated.flowersHeld, 2);
      expect(updated.orientation, Direction.north);
    });

    test('should serialize to JSON', () {
      final robot = Robot(
        position: const Position(x: 2, y: 3),
        orientation: Direction.east,
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: const [Position(x: 1, y: 1)],
      );

      final json = robot.toJson();

      expect(json['position']['x'], 2);
      expect(json['position']['y'], 3);
      expect(json['orientation'], 'east');
      expect(json['flowers']['collected'], isA<List>());
      expect(json['flowers']['delivered'], isA<List>());
    });

    test('should deserialize from JSON', () {
      final json = {
        'position': {'x': 2, 'y': 3},
        'orientation': 'south',
        'flowers': {
          'collected': [
            {'position': {'x': 1, 'y': 1}},
            {'position': {'x': 2, 'y': 2}},
          ],
          'delivered': [
            {'position': {'x': 1, 'y': 1}},
          ],
          'collection_capacity': 12,
        },
        'obstacles': {
          'cleaned': [],
        },
        'executed_actions': [],
      };

      final robot = Robot.fromJson(json);

      expect(robot.position.x, 2);
      expect(robot.position.y, 3);
      expect(robot.orientation, Direction.south);
      expect(robot.flowersHeld, 1); // 2 collected - 1 delivered = 1 held
    });

    test('should maintain equality for same values', () {
      final robot1 = Robot(
        position: const Position(x: 1, y: 1),
        orientation: Direction.north,
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: const [Position(x: 1, y: 1)],
      );

      final robot2 = Robot(
        position: const Position(x: 1, y: 1),
        orientation: Direction.north,
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: const [Position(x: 1, y: 1)],
      );

      expect(robot1, robot2);
    });
  });
}
