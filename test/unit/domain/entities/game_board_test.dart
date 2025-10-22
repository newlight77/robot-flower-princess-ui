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
  });
}
