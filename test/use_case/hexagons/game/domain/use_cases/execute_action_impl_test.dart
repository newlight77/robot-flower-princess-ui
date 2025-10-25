import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/shared/error/failures.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';

@GenerateMocks([GameRepository])
import 'execute_action_impl_test.mocks.dart';

void main() {
  late ExecuteActionImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = ExecuteActionImpl(mockRepository);
  });

  final testGame = Game(
    id: 'game-123',
    name: 'Test Game',
    board: const GameBoard(
      width: 5,
      height: 5,
      cells: [],
      robot: Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.north,
        collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
        deliveredFlowers: [Position(x: 1, y: 1)],
      ),
      princess: Princess(position: Position(x: 4, y: 4)),
      flowersRemaining: 3,
      totalObstacles: 0,
      obstaclesRemaining: 0,
    ),
    status: GameStatus.playing,
    createdAt: DateTime.now(),
  );

  group('ExecuteActionImpl', () {
    test('should execute move action successfully', () async {
      when(mockRepository.executeAction(any, any, any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase(
        'game-123',
        ActionType.move,
        Direction.north,
      );

      expect(result, Right(testGame));
      verify(mockRepository.executeAction(
        'game-123',
        ActionType.move,
        Direction.north,
      ));
    });

    test('should execute pick flower action successfully', () async {
      when(mockRepository.executeAction(any, any, any))
          .thenAnswer((_) async => Right(testGame));

      final result = await useCase(
        'game-123',
        ActionType.pickFlower,
        Direction.east,
      );

      expect(result.isRight(), true);
      verify(mockRepository.executeAction(
        'game-123',
        ActionType.pickFlower,
        Direction.east,
      ));
    });

    test('should return ValidationFailure when gameId is empty', () async {
      final result = await useCase(
        '',
        ActionType.move,
        Direction.north,
      );

      expect(result, const Left(ValidationFailure('Game ID cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return GameOverFailure when action is invalid', () async {
      when(mockRepository.executeAction(any, any, any))
          .thenAnswer((_) async => const Left(GameOverFailure('Invalid move')));

      final result = await useCase(
        'game-123',
        ActionType.move,
        Direction.north,
      );

      expect(result, const Left(GameOverFailure('Invalid move')));
    });
  });
}
