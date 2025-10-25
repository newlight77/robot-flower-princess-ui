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
import 'package:robot_flower_princess_front/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([GameRepository])
import 'auto_play_impl_test.mocks.dart';

void main() {
  late AutoPlayImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = AutoPlayImpl(mockRepository);
  });

  final testGameBefore = Game(
    id: 'game-123',
    name: 'Auto Play Test',
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

  final testGameAfter = Game(
    id: 'game-123',
    name: 'Auto Play Test',
    board: const GameBoard(
      width: 10,
      height: 10,
      cells: [],
      robot: Robot(
        position: Position(x: 9, y: 9),
        orientation: Direction.north,
        collectedFlowers: [],
        deliveredFlowers: [
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
          Position(x: 3, y: 3),
          Position(x: 4, y: 4),
          Position(x: 5, y: 5),
        ],
      ),
      princess: Princess(position: Position(x: 9, y: 9), flowersReceived: 5),
      flowersRemaining: 0,
      totalObstacles: 3,
      obstaclesRemaining: 0,
    ),
    status: GameStatus.won,
    createdAt: DateTime.now(),
  );

  group('AutoPlayImpl', () {
    test('should auto-play game successfully with valid game ID', () async {
      when(mockRepository.autoPlay(any))
          .thenAnswer((_) async => Right(testGameAfter));

      final result = await useCase('game-123');

      expect(result, Right(testGameAfter));
      verify(mockRepository.autoPlay('game-123'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when game ID is empty', () async {
      final result = await useCase('');

      expect(result, const Left(ValidationFailure('Game ID cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return NotFoundFailure when game does not exist', () async {
      when(mockRepository.autoPlay(any)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Game not found')));

      final result = await useCase('non-existent-game');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.autoPlay('non-existent-game'));
    });

    test('should return ServerFailure when repository fails', () async {
      when(mockRepository.autoPlay(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to auto-play game')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.autoPlay('game-123'));
    });

    test('should handle network failures', () async {
      when(mockRepository.autoPlay(any)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.autoPlay('game-123'));
    });

    test('should return game with won status after auto-play', () async {
      when(mockRepository.autoPlay(any))
          .thenAnswer((_) async => Right(testGameAfter));

      final result = await useCase('game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned a game'),
        (game) {
          expect(game.status, GameStatus.won);
          expect(game.board.flowersRemaining, 0);
          expect(game.board.obstaclesRemaining, 0);
        },
      );
    });

    test('should handle auto-play resulting in gameOver', () async {
      final gameOverGame = testGameBefore.copyWith(status: GameStatus.gameOver);
      when(mockRepository.autoPlay(any))
          .thenAnswer((_) async => Right(gameOverGame));

      final result = await useCase('game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned a game'),
        (game) => expect(game.status, GameStatus.gameOver),
      );
    });

    test('should return GameOverFailure if game is already over', () async {
      when(mockRepository.autoPlay(any)).thenAnswer(
          (_) async => const Left(GameOverFailure('Game is already finished')));

      final result = await useCase('game-won-already');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<GameOverFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.autoPlay('game-won-already'));
    });

    test('should verify robot reached princess after auto-play', () async {
      when(mockRepository.autoPlay(any))
          .thenAnswer((_) async => Right(testGameAfter));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned a game'),
        (game) {
          expect(game.board.robot.position, game.board.princess.position);
          expect(game.board.princess.flowersReceived, 5);
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
        when(mockRepository.autoPlay(gameId))
            .thenAnswer((_) async => Right(testGameAfter));

        final result = await useCase(gameId);

        expect(result.isRight(), true);
        verify(mockRepository.autoPlay(gameId));
      }
    });

    test('should handle validation failure from repository', () async {
      when(mockRepository.autoPlay(any)).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid game state')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('should preserve game ID after auto-play', () async {
      when(mockRepository.autoPlay(any))
          .thenAnswer((_) async => Right(testGameAfter));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned a game'),
        (game) => expect(game.id, 'game-123'),
      );
    });
  });
}
