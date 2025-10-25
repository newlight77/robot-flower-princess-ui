import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';

void main() {
  group('Failures', () {
    group('ServerFailure', () {
      test('should create failure with default message', () {
        const failure = ServerFailure();

        expect(failure, isA<Failure>());
        expect(failure.message, 'Server error occurred');
      });

      test('should create failure with custom message', () {
        const failure = ServerFailure('Custom server error');

        expect(failure, isA<Failure>());
        expect(failure.message, 'Custom server error');
      });

      test('should have props for equality', () {
        const failure1 = ServerFailure('Error 1');
        const failure2 = ServerFailure('Error 1');
        const failure3 = ServerFailure('Error 2');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('should support equatable props', () {
        const failure = ServerFailure('Test error');

        expect(failure.props, ['Test error']);
      });
    });

    group('NetworkFailure', () {
      test('should create failure with default message', () {
        const failure = NetworkFailure();

        expect(failure, isA<Failure>());
        expect(failure.message, 'Network connection failed');
      });

      test('should create failure with custom message', () {
        const failure = NetworkFailure('No internet connection');

        expect(failure, isA<Failure>());
        expect(failure.message, 'No internet connection');
      });

      test('should have props for equality', () {
        const failure1 = NetworkFailure('Error 1');
        const failure2 = NetworkFailure('Error 1');
        const failure3 = NetworkFailure('Error 2');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ValidationFailure', () {
      test('should create failure with default message', () {
        const failure = ValidationFailure();

        expect(failure, isA<Failure>());
        expect(failure.message, 'Validation error');
      });

      test('should create failure with custom message', () {
        const failure = ValidationFailure('Invalid input data');

        expect(failure, isA<Failure>());
        expect(failure.message, 'Invalid input data');
      });

      test('should have props for equality', () {
        const failure1 = ValidationFailure('Error 1');
        const failure2 = ValidationFailure('Error 1');
        const failure3 = ValidationFailure('Error 2');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('GameOverFailure', () {
      test('should create failure with default message', () {
        const failure = GameOverFailure();

        expect(failure, isA<Failure>());
        expect(failure.message, 'Game Over');
      });

      test('should create failure with custom message', () {
        const failure = GameOverFailure('You lost the game');

        expect(failure, isA<Failure>());
        expect(failure.message, 'You lost the game');
      });

      test('should have props for equality', () {
        const failure1 = GameOverFailure('Error 1');
        const failure2 = GameOverFailure('Error 1');
        const failure3 = GameOverFailure('Error 2');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('NotFoundFailure', () {
      test('should create failure with default message', () {
        const failure = NotFoundFailure();

        expect(failure, isA<Failure>());
        expect(failure.message, 'Resource not found');
      });

      test('should create failure with custom message', () {
        const failure = NotFoundFailure('Game not found');

        expect(failure, isA<Failure>());
        expect(failure.message, 'Game not found');
      });

      test('should have props for equality', () {
        const failure1 = NotFoundFailure('Error 1');
        const failure2 = NotFoundFailure('Error 1');
        const failure3 = NotFoundFailure('Error 2');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('Failure hierarchy', () {
      test('all failures should extend Failure', () {
        const server = ServerFailure();
        const network = NetworkFailure();
        const validation = ValidationFailure();
        const gameOver = GameOverFailure();
        const notFound = NotFoundFailure();

        expect(server, isA<Failure>());
        expect(network, isA<Failure>());
        expect(validation, isA<Failure>());
        expect(gameOver, isA<Failure>());
        expect(notFound, isA<Failure>());
      });

      test('failures should be distinguishable', () {
        const server = ServerFailure();
        const network = NetworkFailure();
        const validation = ValidationFailure();
        const gameOver = GameOverFailure();
        const notFound = NotFoundFailure();

        expect(server, isNot(isA<NetworkFailure>()));
        expect(network, isNot(isA<ValidationFailure>()));
        expect(validation, isNot(isA<GameOverFailure>()));
        expect(gameOver, isNot(isA<NotFoundFailure>()));
        expect(notFound, isNot(isA<ServerFailure>()));
      });

      test('failures with same message and type should be equal', () {
        const failure1 = ServerFailure('Same error');
        const failure2 = ServerFailure('Same error');

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('failures with different messages should not be equal', () {
        const failure1 = ServerFailure('Error 1');
        const failure2 = ServerFailure('Error 2');

        expect(failure1, isNot(equals(failure2)));
      });

      test(
          'failures of different types should not be equal even with same message',
          () {
        const failure1 = ServerFailure('Same message');
        const failure2 = NetworkFailure('Same message');

        expect(failure1, isNot(equals(failure2)));
      });
    });

    group('Failure usage in error handling', () {
      test('should allow pattern matching', () {
        Failure createFailure(String type) {
          switch (type) {
            case 'server':
              return const ServerFailure('Server failed');
            case 'network':
              return const NetworkFailure('Network failed');
            case 'validation':
              return const ValidationFailure('Validation failed');
            case 'game_over':
              return const GameOverFailure('Game over');
            case 'not_found':
              return const NotFoundFailure('Not found');
            default:
              return const ServerFailure('Unknown error');
          }
        }

        expect(createFailure('server'), isA<ServerFailure>());
        expect(createFailure('network'), isA<NetworkFailure>());
        expect(createFailure('validation'), isA<ValidationFailure>());
        expect(createFailure('game_over'), isA<GameOverFailure>());
        expect(createFailure('not_found'), isA<NotFoundFailure>());
      });

      test('should work in Result pattern (Either)', () {
        // Simulating Either<Failure, Success> pattern
        dynamic handleResult(bool success) {
          if (success) {
            return 'Success';
          } else {
            return const ServerFailure('Operation failed');
          }
        }

        final failure = handleResult(false);
        expect(failure, isA<Failure>());
        expect((failure as Failure).message, 'Operation failed');

        final success = handleResult(true);
        expect(success, isA<String>());
        expect(success, 'Success');
      });

      test('should be usable in collections', () {
        const failures = <Failure>[
          ServerFailure('Error 1'),
          NetworkFailure('Error 2'),
          ValidationFailure('Error 3'),
          GameOverFailure('Error 4'),
          NotFoundFailure('Error 5'),
        ];

        expect(failures.length, 5);
        expect(failures[0], isA<ServerFailure>());
        expect(failures[1], isA<NetworkFailure>());
        expect(failures[2], isA<ValidationFailure>());
        expect(failures[3], isA<GameOverFailure>());
        expect(failures[4], isA<NotFoundFailure>());
      });

      test('should support toString', () {
        const failure = ServerFailure('Test error');

        final str = failure.toString();

        expect(str, contains('ServerFailure'));
      });
    });

    group('Equatable functionality', () {
      test('should use Equatable props for equality', () {
        const failure1 = ServerFailure('Test');
        const failure2 = ServerFailure('Test');
        const failure3 = ServerFailure('Different');

        expect(failure1.props, equals(failure2.props));
        expect(failure1.props, isNot(equals(failure3.props)));
      });

      test('should support Set operations', () {
        // ignore: equal_elements_in_set
        final set = <Failure>{
          const ServerFailure('Error 1'),
          // ignore: equal_elements_in_set
          const ServerFailure('Error 1'), // Duplicate (intentionally testing)
          const NetworkFailure('Error 2'),
        };

        expect(set.length, 2); // Duplicate removed
      });

      test('should support Map keys', () {
        final map = <Failure, String>{
          const ServerFailure('Error 1'): 'Server error',
          const NetworkFailure('Error 2'): 'Network error',
        };

        expect(map[const ServerFailure('Error 1')], 'Server error');
        expect(map[const NetworkFailure('Error 2')], 'Network error');
      });
    });
  });
}
