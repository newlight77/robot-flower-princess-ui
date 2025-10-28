import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_action.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

void main() {
  group('GameAction Entity', () {
    final testTimestamp = DateTime(2025, 10, 24, 12, 0, 0);
    final testAction = GameAction(
      type: ActionType.move,
      direction: Direction.NORTH,
      timestamp: testTimestamp,
      success: true,
    );

    test('should create action with required fields', () {
      expect(testAction.type, ActionType.move);
      expect(testAction.direction, Direction.NORTH);
      expect(testAction.timestamp, testTimestamp);
      expect(testAction.success, true);
      expect(testAction.errorMessage, isNull);
    });

    test('should create action with error message', () {
      final action = GameAction(
        type: ActionType.pickFlower,
        direction: Direction.EAST,
        timestamp: testTimestamp,
        success: false,
        errorMessage: 'No flower at this position',
      );

      expect(action.success, false);
      expect(action.errorMessage, 'No flower at this position');
    });

    test('should create copy with modified fields', () {
      final copiedAction = testAction.copyWith(
        type: ActionType.rotate,
        direction: Direction.SOUTH,
        success: false,
        errorMessage: 'Failed to execute',
      );

      expect(copiedAction.type, ActionType.rotate);
      expect(copiedAction.direction, Direction.SOUTH);
      expect(copiedAction.success, false);
      expect(copiedAction.errorMessage, 'Failed to execute');
      expect(copiedAction.timestamp, testAction.timestamp);
    });

    test('should maintain equality for same values', () {
      final action1 = GameAction(
        type: ActionType.move,
        direction: Direction.NORTH,
        timestamp: testTimestamp,
        success: true,
      );
      final action2 = GameAction(
        type: ActionType.move,
        direction: Direction.NORTH,
        timestamp: testTimestamp,
        success: true,
      );

      expect(action1, equals(action2));
      expect(action1.hashCode, equals(action2.hashCode));
    });

    test('should not be equal for different values', () {
      final action1 = GameAction(
        type: ActionType.move,
        direction: Direction.NORTH,
        timestamp: testTimestamp,
      );
      final action2 = GameAction(
        type: ActionType.rotate,
        direction: Direction.NORTH,
        timestamp: testTimestamp,
      );

      expect(action1, isNot(equals(action2)));
    });

    test('should serialize to JSON', () {
      final action = GameAction(
        type: ActionType.pickFlower,
        direction: Direction.EAST,
        timestamp: testTimestamp,
        success: true,
        errorMessage: 'test error',
      );

      final json = action.toJson();

      expect(json['type'], 'pickFlower');
      expect(json['direction'], 'EAST');
      expect(json['timestamp'], testTimestamp.toIso8601String());
      expect(json['success'], true);
      expect(json['errorMessage'], 'test error');
    });

    test('should deserialize from JSON with timestamp', () {
      final json = {
        'type': 'clean',
        'direction': 'WEST',
        'timestamp': '2025-10-24T14:30:00.000',
        'success': false,
        'errorMessage': 'No obstacle here',
      };

      final action = GameAction.fromJson(json);

      expect(action.type, ActionType.clean);
      expect(action.direction, Direction.WEST);
      expect(action.timestamp.year, 2025);
      expect(action.success, false);
      expect(action.errorMessage, 'No obstacle here');
    });

    test('should deserialize from JSON without timestamp (backend format)', () {
      final json = {
        'type': 'giveFlower',
        'direction': 'SOUTH',
      };

      final action = GameAction.fromJson(json);

      expect(action.type, ActionType.giveFlower);
      expect(action.direction, Direction.SOUTH);
      expect(action.timestamp, isNotNull); // Should use current time
      expect(action.success, true); // Default value
      expect(action.errorMessage, isNull);
    });

    test('should handle all action types', () {
      for (final actionType in ActionType.values) {
        final action = GameAction(
          type: actionType,
          direction: Direction.NORTH,
          timestamp: testTimestamp,
        );
        final json = action.toJson();
        final deserializedAction = GameAction.fromJson(json);

        expect(deserializedAction.type, actionType);
      }
    });

    test('should handle all directions', () {
      for (final direction in Direction.values) {
        final action = GameAction(
          type: ActionType.move,
          direction: direction,
          timestamp: testTimestamp,
        );
        final json = action.toJson();
        final deserializedAction = GameAction.fromJson(json);

        expect(deserializedAction.direction, direction);
      }
    });

    test('should default success to true when missing', () {
      final json = {
        'type': 'move',
        'direction': 'NORTH',
      };

      final action = GameAction.fromJson(json);

      expect(action.success, true);
    });
  });
}
