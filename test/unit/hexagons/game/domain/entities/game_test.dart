import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

void main() {
  group('Game Entity', () {
    late Game testGame;

    setUp(() {
      testGame = Game(
        id: 'test-123',
        name: 'Test Game',
        board: const GameBoard(
          width: 10,
          height: 10,
          cells: [],
          robot: Robot(
            position: Position(x: 0, y: 0),
            orientation: Direction.NORTH,
          ),
          princess: Princess(position: Position(x: 9, y: 9)),
          flowersRemaining: 5,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        ),
        status: GameStatus.playing,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('should create game with required fields', () {
      expect(testGame.id, 'test-123');
      expect(testGame.name, 'Test Game');
      expect(testGame.status, GameStatus.playing);
      expect(testGame.board.width, 10);
    });

    test('should have empty actions list by default', () {
      expect(testGame.actions, isEmpty);
    });

    test('should allow creating copy with modified fields', () {
      final updated = testGame.copyWith(
        name: 'Updated Game',
        status: GameStatus.won,
      );

      expect(updated.name, 'Updated Game');
      expect(updated.status, GameStatus.won);
      expect(updated.id, testGame.id);
    });

    test('should serialize to JSON', () {
      final json = testGame.toJson();

      expect(json['id'], 'test-123');
      expect(json['name'], 'Test Game');
      expect(json['status'], 'playing');
      expect(json['board'], isA<Map>());
      expect(json['createdAt'], isA<String>());
    });

    test('should deserialize from JSON', () {
      final json = testGame.toJson();
      final game = Game.fromJson(json);

      expect(game.id, testGame.id);
      expect(game.name, testGame.name);
      expect(game.status, testGame.status);
    });
  });
}
