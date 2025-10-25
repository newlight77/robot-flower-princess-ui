import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/configurator/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    group('static endpoints', () {
      test('games endpoint should be valid', () {
        expect(ApiEndpoints.games, '/api/games/');
        expect(ApiEndpoints.games, startsWith('/api/'));
        expect(ApiEndpoints.games, endsWith('/'));
      });
    });

    group('dynamic endpoints', () {
      test('game endpoint should include game ID', () {
        const testId = 'test-game-123';
        final endpoint = ApiEndpoints.game(testId);

        expect(endpoint, '/api/games/$testId');
        expect(endpoint, contains(testId));
        expect(endpoint, startsWith('/api/games/'));
      });

      test('game endpoint should handle various ID formats', () {
        final ids = [
          'simple-id',
          'uuid-abc-123-def-456',
          '12345',
          'game_with_underscores',
        ];

        for (final id in ids) {
          final endpoint = ApiEndpoints.game(id);
          expect(endpoint, '/api/games/$id');
          expect(endpoint, contains(id));
        }
      });

      test('gameHistory endpoint should include game ID', () {
        const testId = 'test-game-456';
        final endpoint = ApiEndpoints.gameHistory(testId);

        expect(endpoint, '/api/games/$testId/history');
        expect(endpoint, contains(testId));
        expect(endpoint, endsWith('/history'));
      });

      test('gameAction endpoint should include game ID', () {
        const testId = 'test-game-789';
        final endpoint = ApiEndpoints.gameAction(testId);

        expect(endpoint, '/api/games/$testId/action');
        expect(endpoint, contains(testId));
        expect(endpoint, endsWith('/action'));
      });

      test('autoPlay endpoint should include game ID', () {
        const testId = 'test-game-auto';
        final endpoint = ApiEndpoints.autoPlay(testId);

        expect(endpoint, '/api/games/$testId/autoplay');
        expect(endpoint, contains(testId));
        expect(endpoint, endsWith('/autoplay'));
      });
    });

    group('endpoint consistency', () {
      test('all endpoints should start with /api/', () {
        const testId = 'test-id';

        expect(ApiEndpoints.games, startsWith('/api/'));
        expect(ApiEndpoints.game(testId), startsWith('/api/'));
        expect(ApiEndpoints.gameHistory(testId), startsWith('/api/'));
        expect(ApiEndpoints.gameAction(testId), startsWith('/api/'));
        expect(ApiEndpoints.autoPlay(testId), startsWith('/api/'));
      });

      test('all game-specific endpoints should contain game ID', () {
        const testId = 'my-game-id';

        expect(ApiEndpoints.game(testId), contains(testId));
        expect(ApiEndpoints.gameHistory(testId), contains(testId));
        expect(ApiEndpoints.gameAction(testId), contains(testId));
        expect(ApiEndpoints.autoPlay(testId), contains(testId));
      });

      test('endpoints should not have double slashes', () {
        const testId = 'test-id';

        expect(ApiEndpoints.game(testId), isNot(contains('//')));
        expect(ApiEndpoints.gameHistory(testId), isNot(contains('//')));
        expect(ApiEndpoints.gameAction(testId), isNot(contains('//')));
        expect(ApiEndpoints.autoPlay(testId), isNot(contains('//')));
      });
    });

    group('path construction', () {
      test('should construct valid URL paths', () {
        const gameId = 'abc-123';

        final game = ApiEndpoints.game(gameId);
        final history = ApiEndpoints.gameHistory(gameId);
        final action = ApiEndpoints.gameAction(gameId);
        final auto = ApiEndpoints.autoPlay(gameId);

        // All should start with game endpoint
        expect(history, startsWith(game));
        expect(action, startsWith(game));
        expect(auto, startsWith(game));
      });

      test('should handle empty string ID', () {
        final endpoint = ApiEndpoints.game('');

        expect(endpoint, '/api/games/');
      });

      test('should handle ID with special characters', () {
        final testIds = ['id-with-dash', 'id_with_underscore', 'id123'];

        for (final id in testIds) {
          final endpoint = ApiEndpoints.game(id);
          expect(endpoint, contains(id));
        }
      });
    });
  });
}
