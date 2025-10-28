import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

void main() {
  group('Robot Entity', () {
    test('should create robot with valid parameters', () {
      const robot = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      );

      expect(robot.position.x, 0);
      expect(robot.position.y, 0);
      expect(robot.orientation, Direction.NORTH);
      expect(robot.flowersHeld, 0);
    });

    test('should check if robot has flowers', () {
      const robotWithFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      );

      const robotWithoutFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      );

      expect(robotWithFlowers.hasFlowers, true);
      expect(robotWithoutFlowers.hasFlowers, false);
    });

    test('should check if robot can pick more flowers', () {
      const robotCanPick = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      );

      final robotFull = Robot(
        position: const Position(x: 0, y: 0),
        orientation: Direction.NORTH,
        collectedFlowers: List.generate(12, (i) => Position(x: i, y: 0)),
      );

      expect(robotCanPick.canPickMore, true);
      expect(robotFull.canPickMore, false);
    });

    test('should create copy with updated fields', () {
      const original = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      );

      final updated = original.copyWith(
        position: const Position(x: 1, y: 1),
        collectedFlowers: const [Position(x: 1, y: 1), Position(x: 2, y: 2)],
      );

      expect(updated.position.x, 1);
      expect(updated.position.y, 1);
      expect(updated.flowersHeld, 2);
      expect(updated.orientation, Direction.NORTH);
    });

    test('should serialize to JSON', () {
      const robot = Robot(
        position: Position(x: 2, y: 3),
        orientation: Direction.EAST,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      );

      final json = robot.toJson();

      expect(json['position']['x'], 2);
      expect(json['position']['y'], 3);
      expect(json['orientation'], 'EAST');
      expect(json['flowers']['collected'], isA<List>());
      expect(json['flowers']['delivered'], isA<List>());
    });

    test('should deserialize from JSON (wrapped position format)', () {
      final json = {
        'position': {'x': 2, 'y': 3},
        'orientation': 'SOUTH',
        'flowers': {
          'collected': [
            {
              'position': {'x': 1, 'y': 1}
            },
            {
              'position': {'x': 2, 'y': 2}
            },
          ],
          'delivered': [
            {
              'position': {'x': 1, 'y': 1}
            },
          ],
          'collection_capacity': 12,
        },
        'obstacles': {
          'cleaned': [
            {
              'position': {'row': 0, 'col': 0}
            },
          ],
        },
        'executed_actions': [],
      };

      final robot = Robot.fromJson(json);

      expect(robot.position.x, 2);
      expect(robot.position.y, 3);
      expect(robot.orientation, Direction.SOUTH);
      expect(robot.flowersHeld, 1); // 2 collected - 1 delivered = 1 held
      expect(robot.cleanedObstacles.length, 1);
    });

    test('should deserialize from JSON (direct position format)', () {
      final json = {
        'position': {'row': 3, 'col': 0},
        'orientation': 'SOUTH',
        'flowers': {
          'collected': [],
          'delivered': [],
          'collection_capacity': 12,
        },
        'obstacles': {
          'cleaned': [
            {'row': 4, 'col': 0},
          ],
        },
        'executed_actions': [
          {
            'type': 'move',
            'direction': 'SOUTH',
            'executed_at': '2025-10-26T21:13:32.447629'
          },
        ],
      };

      final robot = Robot.fromJson(json);

      expect(robot.position.x, 0);
      expect(robot.position.y, 3);
      expect(robot.orientation, Direction.SOUTH);
      expect(robot.collectedFlowers.length, 0);
      expect(robot.deliveredFlowers.length, 0);
      expect(robot.cleanedObstacles.length, 1);
      expect(robot.cleanedObstacles.first.x, 0);
      expect(robot.cleanedObstacles.first.y, 4);
      expect(robot.executedActions.length, 1);
      expect(robot.collectionCapacity, 12);
    });

    test('should maintain equality for same values', () {
      const robot1 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.NORTH,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      );

      const robot2 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.NORTH,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      );

      expect(robot1, robot2);
    });
  });
}
