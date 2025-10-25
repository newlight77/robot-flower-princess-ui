import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([GameRepository])
import 'get_game_impl_test.mocks.dart';

void main() {
  late GetGameImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = GetGameImpl(mockRepository);
  });

  final testGame = Game(
    id: 'game-123',
    name: 'Test Game',
    board: const GameBoard(
      width: 10,
      height: 10,
      cells: [],
      robot: Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
      ),
      princess: Princess(position: Position(x: 9, y: 9)),
      flowersRemaining: 5,
      totalObstacles: 3,
      obstaclesRemaining: 3,
    ),
    status: GameStatus.playing,
    createdAt: DateTime.now(),
  );

  group('GetGameImpl', () {
    test('should retrieve game successfully with valid game ID', () async {
      when(mockRepository.getGame(any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase('game-123');

      expect(result, Right(testGame));
      verify(mockRepository.getGame('game-123'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when game ID is empty', () async {
      final result = await useCase('');

      expect(result, const Left(ValidationFailure('Game ID cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return NotFoundFailure when game does not exist', () async {
      when(mockRepository.getGame(any)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Game not found')));

      final result = await useCase('non-existent-game');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.getGame('non-existent-game'));
    });

    test('should return ServerFailure when repository fails', () async {
      when(mockRepository.getGame(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to fetch game')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.getGame('game-123'));
    });

    test('should handle network failures', () async {
      when(mockRepository.getGame(any)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.getGame('game-123'));
    });

    test('should retrieve game with different statuses', () async {
      final wonGame = testGame.copyWith(status: GameStatus.won);
      when(mockRepository.getGame(any)).thenAnswer((_) async => Right(wonGame));

      final result = await useCase('game-won-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned a game'),
        (game) => expect(game.status, GameStatus.won),
      );
    });

    test('should retrieve game with gameOver status', () async {
      final gameOverGame = testGame.copyWith(status: GameStatus.gameOver);
      when(mockRepository.getGame(any))
          .thenAnswer((_) async => Right(gameOverGame));

      final result = await useCase('game-over-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned a game'),
        (game) => expect(game.status, GameStatus.gameOver),
      );
    });

    test('should pass through repository game unchanged', () async {
      when(mockRepository.getGame(any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned a game'),
        (game) {
          expect(game.id, testGame.id);
          expect(game.name, testGame.name);
          expect(game.status, testGame.status);
          expect(game.board.width, testGame.board.width);
          expect(game.board.height, testGame.board.height);
        },
      );
    });

    test('should work with various game ID formats', () async {
      final gameIds = [
        'game-123',
        'abc123',
        'test_game_1',
        'GAME-UPPER-CASE',
        '12345',
      ];

      for (final gameId in gameIds) {
        when(mockRepository.getGame(gameId))
            .thenAnswer((_) async => Right(testGame));

        final result = await useCase(gameId);

        expect(result.isRight(), true);
        verify(mockRepository.getGame(gameId));
      }
    });
  });
}
