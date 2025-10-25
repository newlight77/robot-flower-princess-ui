import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

@GenerateMocks([GameRepository])
import 'create_game_impl_test.mocks.dart';

void main() {
  late CreateGameImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = CreateGameImpl(mockRepository);
  });

  final testGame = Game(
    id: '1',
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
      totalObstacles: 0,
      obstaclesRemaining: 0,
    ),
    status: GameStatus.playing,
    createdAt: DateTime.now(),
  );

  group('CreateGameImpl', () {
    test('should create game successfully with valid parameters', () async {
      when(mockRepository.createGame(any, any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase('Test Game', 10);

      expect(result, Right(testGame));
      verify(mockRepository.createGame('Test Game', 10));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when name is empty', () async {
      final result = await useCase('', 10);

      expect(
          result, const Left(ValidationFailure('Game name cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when board size is too small',
        () async {
      final result = await useCase('Test Game', 2);

      expect(
        result,
        const Left(ValidationFailure('Board size must be between 3 and 50')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when board size is too large',
        () async {
      final result = await useCase('Test Game', 51);

      expect(
        result,
        const Left(ValidationFailure('Board size must be between 3 and 50')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should accept minimum valid board size', () async {
      when(mockRepository.createGame(any, any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase('Test Game', 3);

      expect(result.isRight(), true);
      verify(mockRepository.createGame('Test Game', 3));
    });

    test('should accept maximum valid board size', () async {
      when(mockRepository.createGame(any, any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase('Test Game', 50);

      expect(result.isRight(), true);
      verify(mockRepository.createGame('Test Game', 50));
    });
  });
}
