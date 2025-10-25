import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/shared/error/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('ServerException', () {
      test('should create exception with default message', () {
        final exception = ServerException();

        expect(exception, isA<Exception>());
        expect(exception.message, 'Server error occurred');
      });

      test('should create exception with custom message', () {
        final exception = ServerException('Custom server error');

        expect(exception, isA<Exception>());
        expect(exception.message, 'Custom server error');
      });

      test('should be throwable', () {
        expect(
          () => throw ServerException('Error'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('NetworkException', () {
      test('should create exception with default message', () {
        final exception = NetworkException();

        expect(exception, isA<Exception>());
        expect(exception.message, 'Network connection failed');
      });

      test('should create exception with custom message', () {
        final exception = NetworkException('No internet connection');

        expect(exception, isA<Exception>());
        expect(exception.message, 'No internet connection');
      });

      test('should be throwable', () {
        expect(
          () => throw NetworkException('Timeout'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('ValidationException', () {
      test('should create exception with default message', () {
        final exception = ValidationException();

        expect(exception, isA<Exception>());
        expect(exception.message, 'Validation error');
      });

      test('should create exception with custom message', () {
        final exception = ValidationException('Invalid input data');

        expect(exception, isA<Exception>());
        expect(exception.message, 'Invalid input data');
      });

      test('should be throwable', () {
        expect(
          () => throw ValidationException('Field is required'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('GameOverException', () {
      test('should create exception with default message', () {
        final exception = GameOverException();

        expect(exception, isA<Exception>());
        expect(exception.message, 'Game Over');
      });

      test('should create exception with custom message', () {
        final exception = GameOverException('You lost the game');

        expect(exception, isA<Exception>());
        expect(exception.message, 'You lost the game');
      });

      test('should be throwable', () {
        expect(
          () => throw GameOverException('Game ended'),
          throwsA(isA<GameOverException>()),
        );
      });
    });

    group('NotFoundException', () {
      test('should create exception with default message', () {
        final exception = NotFoundException();

        expect(exception, isA<Exception>());
        expect(exception.message, 'Resource not found');
      });

      test('should create exception with custom message', () {
        final exception = NotFoundException('Game not found');

        expect(exception, isA<Exception>());
        expect(exception.message, 'Game not found');
      });

      test('should be throwable', () {
        expect(
          () => throw NotFoundException('User not found'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('Exception hierarchy', () {
      test('all exceptions should implement Exception', () {
        expect(ServerException(), isA<Exception>());
        expect(NetworkException(), isA<Exception>());
        expect(ValidationException(), isA<Exception>());
        expect(GameOverException(), isA<Exception>());
        expect(NotFoundException(), isA<Exception>());
      });

      test('exceptions should be distinguishable', () {
        final server = ServerException();
        final network = NetworkException();
        final validation = ValidationException();
        final gameOver = GameOverException();
        final notFound = NotFoundException();

        expect(server, isNot(isA<NetworkException>()));
        expect(network, isNot(isA<ValidationException>()));
        expect(validation, isNot(isA<GameOverException>()));
        expect(gameOver, isNot(isA<NotFoundException>()));
        expect(notFound, isNot(isA<ServerException>()));
      });
    });

    group('Exception usage in error handling', () {
      test('should be catchable in try-catch', () {
        String? caughtMessage;

        try {
          throw ServerException('Test error');
        } catch (e) {
          if (e is ServerException) {
            caughtMessage = e.message;
          }
        }

        expect(caughtMessage, 'Test error');
      });

      test('should allow pattern matching', () {
        Exception createException(String type) {
          switch (type) {
            case 'server':
              return ServerException('Server failed');
            case 'network':
              return NetworkException('Network failed');
            case 'validation':
              return ValidationException('Validation failed');
            case 'game_over':
              return GameOverException('Game over');
            case 'not_found':
              return NotFoundException('Not found');
            default:
              return Exception('Unknown error');
          }
        }

        expect(createException('server'), isA<ServerException>());
        expect(createException('network'), isA<NetworkException>());
        expect(createException('validation'), isA<ValidationException>());
        expect(createException('game_over'), isA<GameOverException>());
        expect(createException('not_found'), isA<NotFoundException>());
      });
    });
  });
}
