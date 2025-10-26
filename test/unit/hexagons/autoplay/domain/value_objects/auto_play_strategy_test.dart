import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/autoplay/domain/value_objects/auto_play_strategy.dart';

void main() {
  group('AutoPlayStrategy', () {
    group('toApiParam', () {
      test('should return "greedy" for greedy strategy', () {
        expect(AutoPlayStrategy.greedy.toApiParam(), 'greedy');
      });

      test('should return "optimal" for optimal strategy', () {
        expect(AutoPlayStrategy.optimal.toApiParam(), 'optimal');
      });

      test('should return "ml" for ml strategy', () {
        expect(AutoPlayStrategy.ml.toApiParam(), 'ml');
      });
    });

    group('fromString', () {
      test('should parse "greedy" string to greedy strategy', () {
        expect(AutoPlayStrategy.fromString('greedy'), AutoPlayStrategy.greedy);
      });

      test('should parse "optimal" string to optimal strategy', () {
        expect(
            AutoPlayStrategy.fromString('optimal'), AutoPlayStrategy.optimal);
      });

      test('should parse "ml" string to ml strategy', () {
        expect(AutoPlayStrategy.fromString('ml'), AutoPlayStrategy.ml);
      });

      test('should be case insensitive', () {
        expect(AutoPlayStrategy.fromString('GREEDY'), AutoPlayStrategy.greedy);
        expect(
            AutoPlayStrategy.fromString('Optimal'), AutoPlayStrategy.optimal);
        expect(AutoPlayStrategy.fromString('ML'), AutoPlayStrategy.ml);
      });

      test('should default to greedy for unknown string', () {
        expect(AutoPlayStrategy.fromString('unknown'), AutoPlayStrategy.greedy);
        expect(AutoPlayStrategy.fromString(''), AutoPlayStrategy.greedy);
      });
    });

    group('description', () {
      test('should return correct description for greedy strategy', () {
        expect(AutoPlayStrategy.greedy.description,
            'Safe & reliable (75% success rate)');
      });

      test('should return correct description for optimal strategy', () {
        expect(AutoPlayStrategy.optimal.description,
            'Fast & efficient (62% success, -25% actions)');
      });

      test('should return correct description for ml strategy', () {
        expect(AutoPlayStrategy.ml.description,
            'Hybrid ML/heuristic - Learns from patterns');
      });
    });

    group('successRate', () {
      test('should return 75 for greedy strategy', () {
        expect(AutoPlayStrategy.greedy.successRate, 75);
      });

      test('should return 62 for optimal strategy', () {
        expect(AutoPlayStrategy.optimal.successRate, 62);
      });

      test('should return 85 for ml strategy', () {
        expect(AutoPlayStrategy.ml.successRate, 85);
      });

      test('should have all success rates as positive integers', () {
        for (final strategy in AutoPlayStrategy.values) {
          expect(strategy.successRate, greaterThan(0));
          expect(strategy.successRate, lessThanOrEqualTo(100));
        }
      });
    });

    group('enum values', () {
      test('should have exactly three strategies', () {
        expect(AutoPlayStrategy.values.length, 3);
      });

      test('should contain greedy, optimal, and ml strategies', () {
        expect(AutoPlayStrategy.values, contains(AutoPlayStrategy.greedy));
        expect(AutoPlayStrategy.values, contains(AutoPlayStrategy.optimal));
        expect(AutoPlayStrategy.values, contains(AutoPlayStrategy.ml));
      });
    });

    group('roundtrip conversion', () {
      test('should convert to API param and back for all strategies', () {
        for (final strategy in AutoPlayStrategy.values) {
          final apiParam = strategy.toApiParam();
          final parsed = AutoPlayStrategy.fromString(apiParam);
          expect(parsed, strategy);
        }
      });
    });
  });
}
