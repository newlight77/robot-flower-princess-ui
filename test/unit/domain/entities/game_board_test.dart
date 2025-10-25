import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/entities/cell.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/cell_type.dart';

void main() {
  group('GameBoard Entity', () {
    late GameBoard testBoard;

    setUp(() {
      testBoard = const GameBoard(
        width: 5,
        height: 5,
        cells: [
          Cell(position: Position(x: 0, y: 0), type: CellType.empty),
          Cell(position: Position(x: 1, y: 1), type: CellType.flower),
          Cell(position: Position(x: 2, y: 2), type: CellType.obstacle),
        ],
        robot: Robot(
          position: Position(x: 0, y: 0),
          orientation: Direction.north,
        ),
        princess: Princess(position: Position(x: 4, y: 4)),
        flowersRemaining: 3,
        totalObstacles: 1,
        obstaclesRemaining: 1,
      );
    });

    test('should get cell at position', () {
      final cell = testBoard.getCellAt(const Position(x: 1, y: 1));
      expect(cell, isNotNull);
      expect(cell!.type, CellType.flower);
    });

    test('should return null for non-existent cell', () {
      final cell = testBoard.getCellAt(const Position(x: 10, y: 10));
      expect(cell, isNull);
    });

    test('should validate positions correctly', () {
      expect(testBoard.isValidPosition(const Position(x: 0, y: 0)), true);
      expect(testBoard.isValidPosition(const Position(x: 4, y: 4)), true);
      expect(testBoard.isValidPosition(const Position(x: 5, y: 5)), false);
      expect(testBoard.isValidPosition(const Position(x: -1, y: 0)), false);
      expect(testBoard.isValidPosition(const Position(x: 0, y: -1)), false);
    });

    test('should calculate remaining flowers', () {
      expect(testBoard.flowersRemaining, 3);

      final updatedBoard = testBoard.copyWith(flowersRemaining: 2);
      expect(updatedBoard.flowersRemaining, 2);
    });

    test('should check if board is complete', () {
      expect(testBoard.isComplete, false);

      final completeBoard = testBoard.copyWith(flowersRemaining: 0);
      expect(completeBoard.isComplete, true);

      final overCompleteBoard = testBoard.copyWith(flowersRemaining: 0);
      expect(overCompleteBoard.isComplete, true);
    });

    test('should serialize to JSON', () {
      final json = testBoard.toJson();

      expect(json['cols'], 5);
      expect(json['rows'], 5);
      expect(json['flowers']['remaining'], 3);
      expect(json['grid'], isA<List>());
      expect(json['robot'], isA<Map>());
      expect(json['princess'], isA<Map>());
    });

    test('should deserialize from JSON', () {
      final json = testBoard.toJson();
      final board = GameBoard.fromJson(json);

      expect(board.width, testBoard.width);
      expect(board.height, testBoard.height);
      expect(board.flowersRemaining, testBoard.flowersRemaining);
      expect(board.robot.position, testBoard.robot.position);
    });

    group('Edge Cases', () {
      test('should handle empty board (no cells)', () {
        const emptyBoard = GameBoard(
          width: 3,
          height: 3,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 2, y: 2)),
          flowersRemaining: 0,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(emptyBoard.cells, isEmpty);
        expect(emptyBoard.getCellAt(const Position(x: 0, y: 0)), isNull);
        expect(emptyBoard.isValidPosition(const Position(x: 1, y: 1)), true);
      });

      test('should handle minimum size board (1x1)', () {
        const minBoard = GameBoard(
          width: 1,
          height: 1,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 0, y: 0)),
          flowersRemaining: 0,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(minBoard.width, 1);
        expect(minBoard.height, 1);
        expect(minBoard.isValidPosition(const Position(x: 0, y: 0)), true);
        expect(minBoard.isValidPosition(const Position(x: 1, y: 0)), false);
        expect(minBoard.isValidPosition(const Position(x: 0, y: 1)), false);
      });

      test('should handle large board', () {
        const largeBoard = GameBoard(
          width: 100,
          height: 100,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 99, y: 99)),
          flowersRemaining: 0,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(largeBoard.width, 100);
        expect(largeBoard.height, 100);
        expect(largeBoard.isValidPosition(const Position(x: 99, y: 99)), true);
        expect(largeBoard.isValidPosition(const Position(x: 100, y: 99)), false);
      });

      test('should handle rectangular boards', () {
        const rectBoard = GameBoard(
          width: 10,
          height: 5,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 9, y: 4)),
          flowersRemaining: 0,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(rectBoard.isValidPosition(const Position(x: 9, y: 4)), true);
        expect(rectBoard.isValidPosition(const Position(x: 9, y: 5)), false);
        expect(rectBoard.isValidPosition(const Position(x: 10, y: 4)), false);
      });

      test('should handle board with maximum flowers', () {
        const boardWithFlowers = GameBoard(
          width: 10,
          height: 10,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 9, y: 9)),
          flowersRemaining: 50,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(boardWithFlowers.flowersRemaining, 50);
        expect(boardWithFlowers.isComplete, false);
      });

      test('should handle board with all obstacles removed', () {
        const boardWithoutObstacles = GameBoard(
          width: 5,
          height: 5,
          cells: [],
          robot: Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
          princess: Princess(position: Position(x: 4, y: 4)),
          flowersRemaining: 3,
          totalObstacles: 5,
          obstaclesRemaining: 0,
        );

        expect(boardWithoutObstacles.totalObstacles, 5);
        expect(boardWithoutObstacles.obstaclesRemaining, 0);
      });

      test('should handle negative coordinates correctly', () {
        expect(testBoard.isValidPosition(const Position(x: -1, y: -1)), false);
        expect(testBoard.isValidPosition(const Position(x: -100, y: 0)), false);
        expect(testBoard.isValidPosition(const Position(x: 0, y: -100)), false);
      });

      test('should handle extremely large coordinates', () {
        expect(testBoard.isValidPosition(const Position(x: 1000, y: 1000)), false);
        expect(testBoard.isValidPosition(const Position(x: 999999, y: 0)), false);
      });

      test('should handle copyWith with no changes', () {
        final copied = testBoard.copyWith();

        expect(copied.width, testBoard.width);
        expect(copied.height, testBoard.height);
        expect(copied.flowersRemaining, testBoard.flowersRemaining);
        expect(copied.robot, testBoard.robot);
        expect(copied.princess, testBoard.princess);
      });

      test('should handle copyWith with all fields changed', () {
        const newRobot = Robot(position: Position(x: 2, y: 2), orientation: Direction.south);
        const newPrincess = Princess(position: Position(x: 3, y: 3));

        final copied = testBoard.copyWith(
          width: 10,
          height: 10,
          cells: [],
          robot: newRobot,
          princess: newPrincess,
          flowersRemaining: 5,
          totalObstacles: 3,
          obstaclesRemaining: 2,
        );

        expect(copied.width, 10);
        expect(copied.height, 10);
        expect(copied.flowersRemaining, 5);
        expect(copied.totalObstacles, 3);
        expect(copied.obstaclesRemaining, 2);
        expect(copied.robot, newRobot);
        expect(copied.princess, newPrincess);
      });

      test('should handle board with robot and princess at same position', () {
        const samePositionBoard = GameBoard(
          width: 5,
          height: 5,
          cells: [],
          robot: Robot(position: Position(x: 2, y: 2), orientation: Direction.north),
          princess: Princess(position: Position(x: 2, y: 2)),
          flowersRemaining: 0,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        expect(samePositionBoard.robot.position, samePositionBoard.princess.position);
        expect(samePositionBoard.isComplete, true);
      });

      test('should handle getCellAt with boundary positions', () {
        // Top-left corner
        final topLeft = testBoard.getCellAt(const Position(x: 0, y: 0));
        expect(topLeft?.position, const Position(x: 0, y: 0));

        // Just outside boundaries
        expect(testBoard.getCellAt(const Position(x: 5, y: 0)), isNull);
        expect(testBoard.getCellAt(const Position(x: 0, y: 5)), isNull);
      });

      test('should maintain immutability', () {
        final copied = testBoard.copyWith(flowersRemaining: 0);

        expect(testBoard.flowersRemaining, 3);
        expect(copied.flowersRemaining, 0);
      });
    });
  });
}
