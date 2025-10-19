import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/domain/use_cases/get_games_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([GameRepository])
import 'get_games_impl_test.mocks.dart';

void main() {
  late GetGamesImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = GetGamesImpl(mockRepository);
  });

  final testGames = [
    Game(
      id: '1',
      name: 'Game 1',
      board: const GameBoard(
        width: 5,
        height: 5,
        cells: [],
        robot: Robot(
          position: Position(x: 0, y: 0),
          orientation: Direction.north,
        ),
        princessPosition: Position(x: 4, y: 4),
        totalFlowers: 3,
      ),
      status: GameStatus.playing,
      createdAt: DateTime.now(),
    ),
    Game(
      id: '2',
      name: 'Game 2',
      board: const GameBoard(
        width: 10,
        height: 10,
        cells: [],
        robot: Robot(
          position: Position(x: 0, y: 0),
          orientation: Direction.north,
        ),
        princessPosition: Position(x: 9, y: 9),
        totalFlowers: 5,
      ),
      status: GameStatus.won,
      createdAt: DateTime.now(),
    ),
  ];

  group('GetGamesImpl', () {
    test('should return list of games when repository succeeds', () async {
      when(mockRepository.getGames(limit: anyNamed('limit')))
          .thenAnswer((_) async => Right(testGames));

      final result = await useCase();

      expect(result, Right(testGames));
      expect((result as Right).value.length, 2);
      verify(mockRepository.getGames(limit: anyNamed('limit')));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no games exist', () async {
      when(mockRepository.getGames(limit: anyNamed('limit')))
          .thenAnswer((_) async => const Right(<Game>[]));

      final result = await useCase();

  // Match the successful Right result by asserting on the contained value
  expect((result as Right).value, <Game>[]);
      verify(mockRepository.getGames(limit: anyNamed('limit')));
    });

    test('should return ServerFailure when repository fails', () async {
      when(mockRepository.getGames(limit: anyNamed('limit')))
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      final result = await useCase();

      expect(result, const Left(ServerFailure('Server error')));
      verify(mockRepository.getGames(limit: anyNamed('limit')));
    });
  });
}
