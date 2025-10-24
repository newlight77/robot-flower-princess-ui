import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('API Configuration', () {
      test('should have default base URL', () {
        expect(AppConstants.baseUrl, isNotEmpty);
        expect(AppConstants.baseUrl, contains('http'));
      });

      test('should have API timeout configured', () {
        expect(AppConstants.apiTimeout, isA<Duration>());
        expect(AppConstants.apiTimeout.inSeconds, greaterThan(0));
        expect(AppConstants.apiTimeout.inSeconds, 30);
      });
    });

    group('Game Configuration', () {
      test('should have valid min board size', () {
        expect(AppConstants.minBoardSize, isA<int>());
        expect(AppConstants.minBoardSize, greaterThan(0));
        expect(AppConstants.minBoardSize, 3);
      });

      test('should have valid max board size', () {
        expect(AppConstants.maxBoardSize, isA<int>());
        expect(AppConstants.maxBoardSize, greaterThan(AppConstants.minBoardSize));
        expect(AppConstants.maxBoardSize, 50);
      });

      test('should have valid default board size', () {
        expect(AppConstants.defaultBoardSize, isA<int>());
        expect(
          AppConstants.defaultBoardSize,
          greaterThanOrEqualTo(AppConstants.minBoardSize),
        );
        expect(
          AppConstants.defaultBoardSize,
          lessThanOrEqualTo(AppConstants.maxBoardSize),
        );
        expect(AppConstants.defaultBoardSize, 10);
      });

      test('should have valid max flowers', () {
        expect(AppConstants.maxFlowers, isA<int>());
        expect(AppConstants.maxFlowers, greaterThan(0));
        expect(AppConstants.maxFlowers, 12);
      });

      test('should have valid max flower percentage', () {
        expect(AppConstants.maxFlowerPercentage, isA<double>());
        expect(AppConstants.maxFlowerPercentage, greaterThan(0));
        expect(AppConstants.maxFlowerPercentage, lessThanOrEqualTo(1.0));
        expect(AppConstants.maxFlowerPercentage, 0.10);
      });

      test('should have valid obstacle percentage', () {
        expect(AppConstants.obstaclePercentage, isA<double>());
        expect(AppConstants.obstaclePercentage, greaterThan(0));
        expect(AppConstants.obstaclePercentage, lessThanOrEqualTo(1.0));
        expect(AppConstants.obstaclePercentage, 0.30);
      });

      test('board size constraints should be logical', () {
        expect(
          AppConstants.minBoardSize < AppConstants.maxBoardSize,
          true,
          reason: 'Min board size should be less than max',
        );
        expect(
          AppConstants.defaultBoardSize >= AppConstants.minBoardSize,
          true,
          reason: 'Default should be >= min',
        );
        expect(
          AppConstants.defaultBoardSize <= AppConstants.maxBoardSize,
          true,
          reason: 'Default should be <= max',
        );
      });

      test('percentages should be valid fractions', () {
        expect(
          AppConstants.maxFlowerPercentage + AppConstants.obstaclePercentage,
          lessThan(1.0),
          reason: 'Combined percentages should leave room for robot and princess',
        );
      });
    });

    group('Animation Configuration', () {
      test('should have valid animation duration', () {
        expect(AppConstants.animationDuration, isA<Duration>());
        expect(AppConstants.animationDuration.inMilliseconds, greaterThan(0));
        expect(AppConstants.animationDuration.inMilliseconds, 500);
      });

      test('should have valid replay step duration', () {
        expect(AppConstants.replayStepDuration, isA<Duration>());
        expect(AppConstants.replayStepDuration.inMilliseconds, greaterThan(0));
        expect(AppConstants.replayStepDuration.inMilliseconds, 800);
      });

      test('replay step should be longer than animation for visibility', () {
        expect(
          AppConstants.replayStepDuration > AppConstants.animationDuration,
          true,
          reason: 'Replay steps should be visible before next step',
        );
      });
    });

    group('Storage Keys', () {
      test('should have games list key', () {
        expect(AppConstants.gamesListKey, isNotEmpty);
        expect(AppConstants.gamesListKey, 'games_list');
      });

      test('should have current game key', () {
        expect(AppConstants.currentGameKey, isNotEmpty);
        expect(AppConstants.currentGameKey, 'current_game');
      });

      test('storage keys should be unique', () {
        expect(
          AppConstants.gamesListKey != AppConstants.currentGameKey,
          true,
          reason: 'Storage keys should be unique to avoid conflicts',
        );
      });

      test('storage keys should be valid strings', () {
        expect(AppConstants.gamesListKey, isA<String>());
        expect(AppConstants.currentGameKey, isA<String>());
        expect(AppConstants.gamesListKey.isEmpty, false);
        expect(AppConstants.currentGameKey.isEmpty, false);
      });
    });

    group('Constants immutability', () {
      test('should be compile-time constants where possible', () {
        // These should be const
        expect(AppConstants.apiTimeout, const Duration(seconds: 30));
        expect(AppConstants.animationDuration, const Duration(milliseconds: 500));
        expect(
          AppConstants.replayStepDuration,
          const Duration(milliseconds: 800),
        );
      });
    });

    group('Practical usage', () {
      test('min board size should allow basic game', () {
        // 3x3 should fit robot, princess, and at least one flower
        final minCells = AppConstants.minBoardSize * AppConstants.minBoardSize;
        expect(minCells, greaterThanOrEqualTo(4)); // robot + princess + flower + space
      });

      test('max flowers should fit in default board', () {
        final totalCells =
            AppConstants.defaultBoardSize * AppConstants.defaultBoardSize;
        expect(
          AppConstants.maxFlowers < totalCells,
          true,
          reason: 'Max flowers should fit in default board',
        );
      });

      test('obstacle percentage should leave playable space', () {
        final totalCells =
            AppConstants.defaultBoardSize * AppConstants.defaultBoardSize;
        final maxObstacles = (totalCells * AppConstants.obstaclePercentage).floor();
        final maxFlowers = (totalCells * AppConstants.maxFlowerPercentage).floor();

        // Should have space for robot, princess, obstacles, and flowers
        expect(
          maxObstacles + maxFlowers + 2, // +2 for robot and princess
          lessThan(totalCells),
          reason: 'Board should have playable space',
        );
      });

      test('API timeout should be reasonable', () {
        expect(
          AppConstants.apiTimeout.inSeconds,
          greaterThanOrEqualTo(10),
          reason: 'Timeout should allow for network delays',
        );
        expect(
          AppConstants.apiTimeout.inSeconds,
          lessThanOrEqualTo(60),
          reason: 'Timeout should not be too long',
        );
      });
    });

    group('Type safety', () {
      test('should have correct types for all constants', () {
        expect(AppConstants.baseUrl, isA<String>());
        expect(AppConstants.apiTimeout, isA<Duration>());
        expect(AppConstants.minBoardSize, isA<int>());
        expect(AppConstants.maxBoardSize, isA<int>());
        expect(AppConstants.defaultBoardSize, isA<int>());
        expect(AppConstants.maxFlowers, isA<int>());
        expect(AppConstants.maxFlowerPercentage, isA<double>());
        expect(AppConstants.obstaclePercentage, isA<double>());
        expect(AppConstants.animationDuration, isA<Duration>());
        expect(AppConstants.replayStepDuration, isA<Duration>());
        expect(AppConstants.gamesListKey, isA<String>());
        expect(AppConstants.currentGameKey, isA<String>());
      });
    });
  });
}

