import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/data/models/game_model.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';

void main() {
  group('GameModel', () {
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'id': 'test-game-123',
        'name': 'Test Game',
        'board': {
          'rows': 5,
          'cols': 5,
          'grid': [
            ['⬜', '🤖', '⬜', '⬜', '⬜'],
            ['⬜', '🌸', '⬜', '⬜', '⬜'],
            ['⬜', '⬜', '⬜', '⬜', '⬜'],
            ['⬜', '⬜', '⬜', '⬜', '⬜'],
            ['⬜', '⬜', '⬜', '⬜', '👑'],
          ],
        },
        'robot': {
          'position': {'x': 1, 'y': 0},
          'orientation': 'north',
          'flowers': {
            'collected': [],
            'delivered': [],
            'collection_capacity': 12
          },
          'obstacles': {'cleaned': []},
          'executed_actions': []
        },
        'princess': {
          'position': {'x': 4, 'y': 4},
          'flowers_received': 0,
          'mood': 'neutral'
        },
        'flowers': {'total': 1, 'remaining': 1},
        'obstacles': {'total': 0, 'remaining': 0},
        'status': 'in_progress',
        'actions': [],
        'createdAt': '2024-01-01T10:00:00.000Z',
        'updatedAt': '2024-01-01T10:30:00.000Z',
      };
    });

    group('fromJson', () {
      test('should parse complete valid JSON', () {
        final model = GameModel.fromJson(validJson);

        expect(model.id, 'test-game-123');
        expect(model.name, 'Test Game');
        expect(model.status, GameStatus.playing);
        expect(model.board.width, 5);
        expect(model.board.height, 5);
        expect(model.actions, isEmpty);
        expect(model.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(model.updatedAt, DateTime.parse('2024-01-01T10:30:00.000Z'));
      });

      test('should handle missing id and generate default', () {
        validJson.remove('id');

        final model = GameModel.fromJson(validJson);

        expect(model.id, startsWith('game_'));
        expect(model.id.length, greaterThan(5));
      });

      test('should handle _id field (alternative id format)', () {
        validJson.remove('id');
        validJson['_id'] = 'mongo-id-456';

        final model = GameModel.fromJson(validJson);

        expect(model.id, 'mongo-id-456');
      });

      test('should handle gameId field (alternative id format)', () {
        validJson.remove('id');
        validJson['gameId'] = 'gameId-789';

        final model = GameModel.fromJson(validJson);

        expect(model.id, 'gameId-789');
      });

      test('should handle missing name and generate default', () {
        validJson.remove('name');

        final model = GameModel.fromJson(validJson);

        expect(model.name, startsWith('Game '));
      });

      test('should handle status: in_progress', () {
        validJson['status'] = 'in_progress';

        final model = GameModel.fromJson(validJson);

        expect(model.status, GameStatus.playing);
      });

      test('should handle status: victory', () {
        validJson['status'] = 'victory';

        final model = GameModel.fromJson(validJson);

        expect(model.status, GameStatus.won);
      });

      test('should handle status: game_over', () {
        validJson['status'] = 'game_over';

        final model = GameModel.fromJson(validJson);

        expect(model.status, GameStatus.gameOver);
      });

      test('should default to playing for unknown status', () {
        validJson['status'] = 'unknown_status';

        final model = GameModel.fromJson(validJson);

        expect(model.status, GameStatus.playing);
      });

      test('should handle missing status and default to playing', () {
        validJson.remove('status');

        final model = GameModel.fromJson(validJson);

        expect(model.status, GameStatus.playing);
      });

      test('should handle snake_case createdAt (created_at)', () {
        validJson.remove('createdAt');
        validJson['created_at'] = '2024-02-01T12:00:00.000Z';

        final model = GameModel.fromJson(validJson);

        expect(model.createdAt, DateTime.parse('2024-02-01T12:00:00.000Z'));
      });

      test('should handle snake_case updatedAt (updated_at)', () {
        validJson.remove('updatedAt');
        validJson['updated_at'] = '2024-02-01T13:00:00.000Z';

        final model = GameModel.fromJson(validJson);

        expect(model.updatedAt, DateTime.parse('2024-02-01T13:00:00.000Z'));
      });

      test('should handle missing createdAt and use current time', () {
        validJson.remove('createdAt');
        final before = DateTime.now();

        final model = GameModel.fromJson(validJson);

        final after = DateTime.now();
        expect(
            model.createdAt
                .isAfter(before.subtract(const Duration(seconds: 1))),
            true);
        expect(model.createdAt.isBefore(after.add(const Duration(seconds: 1))),
            true);
      });

      test('should handle missing updatedAt as null', () {
        validJson.remove('updatedAt');

        final model = GameModel.fromJson(validJson);

        expect(model.updatedAt, isNull);
      });

      test('should handle missing actions and default to empty list', () {
        validJson.remove('actions');

        final model = GameModel.fromJson(validJson);

        expect(model.actions, isEmpty);
      });

      test('should parse actions list', () {
        validJson['actions'] = [
          {
            'type': 'move',
            'direction': 'north',
            'timestamp': '2024-01-01T10:05:00.000Z',
            'success': true
          },
          {
            'type': 'pickFlower',
            'direction': 'north',
            'timestamp': '2024-01-01T10:06:00.000Z',
            'success': true
          }
        ];

        final model = GameModel.fromJson(validJson);

        expect(model.actions.length, 2);
        expect(model.actions[0].type.name, 'move');
        expect(model.actions[1].type.name, 'pickFlower');
      });

      test('should handle board data at root level (new format)', () {
        // Remove nested board structure
        validJson.remove('board');
        // Add board dimensions at root
        validJson['rows'] = 5;
        validJson['cols'] = 5;
        validJson['grid'] = [
          ['⬜', '🤖', '⬜', '⬜', '⬜'],
          ['⬜', '🌸', '⬜', '⬜', '⬜'],
          ['⬜', '⬜', '⬜', '⬜', '⬜'],
          ['⬜', '⬜', '⬜', '⬜', '⬜'],
          ['⬜', '⬜', '⬜', '⬜', '👑'],
        ];

        final model = GameModel.fromJson(validJson);

        expect(model.board.width, 5);
        expect(model.board.height, 5);
      });

      test('should throw exception for invalid JSON structure', () {
        final invalidJson = {
          'id': 'test',
          'name': 'Test',
          'rows': 'invalid', // Wrong type - should be int
          'cols': 5,
        };

        expect(
          () => GameModel.fromJson(invalidJson),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception with descriptive message for parsing errors',
          () {
        final invalidJson = {
          'id': 'test',
          'name': 'Test',
          'board': 'invalid_board_data', // Wrong type
        };

        expect(
          () => GameModel.fromJson(invalidJson),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Failed to parse GameModel from JSON')),
          ),
        );
      });
    });

    group('toJson', () {
      late GameModel model;

      setUp(() {
        model = GameModel(
          id: 'test-123',
          name: 'Test Game',
          board: const GameBoard(
            width: 3,
            height: 3,
            cells: [],
            robot: Robot(
              position: Position(x: 0, y: 0),
              orientation: Direction.north,
            ),
            princess: Princess(position: Position(x: 2, y: 2)),
            flowersRemaining: 1,
            totalObstacles: 0,
            obstaclesRemaining: 0,
          ),
          status: GameStatus.playing,
          actions: const [],
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T11:00:00.000Z'),
        );
      });

      test('should convert to JSON with all fields', () {
        final json = model.toJson();

        expect(json['id'], 'test-123');
        expect(json['name'], 'Test Game');
        expect(json['board'], isA<Map<String, dynamic>>());
        expect(json['status'], 'playing');
        expect(json['actions'], isA<List>());
        expect(json['createdAt'], '2024-01-01T10:00:00.000Z');
        expect(json['updatedAt'], '2024-01-01T11:00:00.000Z');
      });

      test('should handle null updatedAt', () {
        final modelWithoutUpdate = GameModel(
          id: 'test-456',
          name: 'Test',
          board: model.board,
          status: GameStatus.playing,
          actions: const [],
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
          updatedAt: null,
        );

        final json = modelWithoutUpdate.toJson();

        expect(json['updatedAt'], isNull);
      });

      test('should serialize status correctly', () {
        final wonModel = GameModel(
          id: 'test',
          name: 'Test',
          board: model.board,
          status: GameStatus.won,
          actions: const [],
          createdAt: DateTime.now(),
        );

        final json = wonModel.toJson();

        expect(json['status'], 'won');
      });

      test('should serialize actions list', () {
        final modelWithActions = GameModel(
          id: 'test',
          name: 'Test',
          board: model.board,
          status: GameStatus.playing,
          actions: const [],
          createdAt: DateTime.now(),
        );

        final json = modelWithActions.toJson();

        expect(json['actions'], isA<List>());
        expect(json['actions'], isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert to Game entity', () {
        const board = GameBoard(
          width: 3,
          height: 3,
          cells: [],
          robot: Robot(
            position: Position(x: 0, y: 0),
            orientation: Direction.north,
          ),
          princess: Princess(position: Position(x: 2, y: 2)),
          flowersRemaining: 1,
          totalObstacles: 0,
          obstaclesRemaining: 0,
        );

        final model = GameModel(
          id: 'test-789',
          name: 'Entity Test',
          board: board,
          status: GameStatus.playing,
          actions: const [],
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T11:00:00.000Z'),
        );

        final entity = model.toEntity();

        expect(entity.id, model.id);
        expect(entity.name, model.name);
        expect(entity.board, model.board);
        expect(entity.status, model.status);
        expect(entity.actions, model.actions);
        expect(entity.createdAt, model.createdAt);
        expect(entity.updatedAt, model.updatedAt);
      });
    });

    group('round-trip conversion', () {
      test('should maintain data integrity through toJson -> fromJson', () {
        final model = GameModel.fromJson(validJson);
        final json = model.toJson();
        final reconstructed = GameModel.fromJson(json);

        expect(reconstructed.id, model.id);
        expect(reconstructed.name, model.name);
        expect(reconstructed.status, model.status);
        expect(reconstructed.board.width, model.board.width);
        expect(reconstructed.board.height, model.board.height);
        expect(reconstructed.createdAt, model.createdAt);
        expect(reconstructed.updatedAt, model.updatedAt);
      });
    });
  });
}
