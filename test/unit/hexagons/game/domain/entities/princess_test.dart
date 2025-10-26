import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';

void main() {
  group('Princess Entity', () {
    const testPosition = Position(x: 5, y: 5);
    const testPrincess = Princess(
      position: testPosition,
      flowersReceivedList: [
        Position(x: 1, y: 1),
        Position(x: 2, y: 2),
        Position(x: 3, y: 3),
      ],
      mood: PrincessMood.happy,
    );

    test('should create princess with all fields', () {
      expect(testPrincess.position, testPosition);
      expect(testPrincess.flowersReceived, 3); // Backward compatibility getter
      expect(testPrincess.flowersReceivedList.length, 3);
      expect(testPrincess.mood, PrincessMood.happy);
    });

    test('should create princess with default values', () {
      const princess = Princess(position: testPosition);

      expect(princess.flowersReceived, 0);
      expect(princess.mood, PrincessMood.neutral);
    });

    test('should create copy with modified fields', () {
      const newPosition = Position(x: 7, y: 8);
      final newFlowersList = List.generate(10, (i) => Position(x: i, y: i));
      final copiedPrincess = testPrincess.copyWith(
        position: newPosition,
        flowersReceivedList: newFlowersList,
        mood: PrincessMood.sad,
      );

      expect(copiedPrincess.position, newPosition);
      expect(copiedPrincess.flowersReceived, 10);
      expect(copiedPrincess.flowersReceivedList.length, 10);
      expect(copiedPrincess.mood, PrincessMood.sad);
    });

    test('should maintain equality for same values', () {
      const princess1 = Princess(
        position: Position(x: 5, y: 5),
        flowersReceivedList: [
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
          Position(x: 3, y: 3)
        ],
        mood: PrincessMood.happy,
      );
      const princess2 = Princess(
        position: Position(x: 5, y: 5),
        flowersReceivedList: [
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
          Position(x: 3, y: 3)
        ],
        mood: PrincessMood.happy,
      );

      expect(princess1, equals(princess2));
      expect(princess1.hashCode, equals(princess2.hashCode));
    });

    test('should not be equal for different values', () {
      const princess1 = Princess(
        position: testPosition,
        flowersReceivedList: [
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
          Position(x: 3, y: 3)
        ],
        mood: PrincessMood.happy,
      );
      const princess2 = Princess(
        position: testPosition,
        flowersReceivedList: [
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
          Position(x: 3, y: 3),
          Position(x: 4, y: 4),
          Position(x: 5, y: 5)
        ],
        mood: PrincessMood.happy,
      );

      expect(princess1, isNot(equals(princess2)));
    });

    test('should serialize to JSON', () {
      final json = testPrincess.toJson();

      expect(json['position'], isA<Map<String, dynamic>>());
      expect(json['position']['x'], 5);
      expect(json['position']['y'], 5);
      expect(json['flowers_received'], isA<List>());
      expect(json['flowers_received'].length, 3);
      expect(json['mood'], 'happy');
    });

    test('should deserialize from JSON with list format (new backend format)',
        () {
      final json = {
        'position': {'row': 8, 'col': 9},
        'flowers_received': [
          {'row': 1, 'col': 1},
          {'row': 2, 'col': 2},
        ],
        'mood': 'angry',
      };

      final princess = Princess.fromJson(json);

      expect(princess.position.x, 9); // col maps to x
      expect(princess.position.y, 8); // row maps to y
      expect(princess.flowersReceived, 2);
      expect(princess.flowersReceivedList.length, 2);
      expect(princess.mood, PrincessMood.angry);
    });

    test(
        'should deserialize from JSON with integer format (backward compatibility)',
        () {
      final json = {
        'position': {'x': 8, 'y': 9},
        'flowers_received': 7,
        'mood': 'angry',
      };

      final princess = Princess.fromJson(json);

      expect(princess.position.x, 8);
      expect(princess.position.y, 9);
      expect(princess.flowersReceived, 7);
      expect(princess.mood, PrincessMood.angry);
    });

    test('should deserialize from JSON with default values', () {
      final json = {
        'position': {'x': 1, 'y': 2},
      };

      final princess = Princess.fromJson(json);

      expect(princess.flowersReceived, 0);
      expect(princess.mood, PrincessMood.neutral);
    });

    test('should handle all mood types in JSON', () {
      final moods = ['happy', 'sad', 'angry', 'neutral'];
      final expectedMoods = [
        PrincessMood.happy,
        PrincessMood.sad,
        PrincessMood.angry,
        PrincessMood.neutral,
      ];

      for (int i = 0; i < moods.length; i++) {
        final json = {
          'position': {'x': 1, 'y': 1},
          'mood': moods[i],
        };

        final princess = Princess.fromJson(json);
        expect(princess.mood, expectedMoods[i]);
      }
    });

    test('should default to neutral mood for unknown mood string', () {
      final json = {
        'position': {'x': 1, 'y': 1},
        'mood': 'unknown_mood',
      };

      final princess = Princess.fromJson(json);
      expect(princess.mood, PrincessMood.neutral);
    });

    test('should throw exception when position is missing', () {
      final json = {
        'flowers_received': 5,
        'mood': 'happy',
      };

      expect(
        () => Princess.fromJson(json),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PrincessMood', () {
    test('should return correct emoji for happy mood', () {
      expect(PrincessMood.happy.emoji, '😊');
    });

    test('should return correct emoji for sad mood', () {
      expect(PrincessMood.sad.emoji, '😢');
    });

    test('should return correct emoji for angry mood', () {
      expect(PrincessMood.angry.emoji, '😠');
    });

    test('should return correct emoji for neutral mood', () {
      expect(PrincessMood.neutral.emoji, '😐');
    });

    test('should have all mood values', () {
      expect(PrincessMood.values.length, 4);
      expect(PrincessMood.values, contains(PrincessMood.happy));
      expect(PrincessMood.values, contains(PrincessMood.sad));
      expect(PrincessMood.values, contains(PrincessMood.angry));
      expect(PrincessMood.values, contains(PrincessMood.neutral));
    });
  });
}
