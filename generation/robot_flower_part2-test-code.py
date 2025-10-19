#!/usr/bin/env python3
"""
Robot Flower Princess - Part 2B: Domain Layer Tests
Generates comprehensive tests for domain layer
"""

import os
import zipfile
from pathlib import Path

def create_directory_structure(base_path):
    """Create the test directory structure"""
    directories = [
        'test/unit/domain/entities',
        'test/unit/domain/value_objects',
        'test/unit/domain/use_cases',
    ]

    for directory in directories:
        Path(os.path.join(base_path, directory)).mkdir(parents=True, exist_ok=True)

def generate_files(base_path):
    """Generate all test files"""

    files = {
        # Entity Tests
        'test/unit/domain/entities/robot_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

void main() {
  group('Robot Entity', () {
    test('should create robot with valid parameters', () {
      const robot = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      expect(robot.position.x, 0);
      expect(robot.position.y, 0);
      expect(robot.orientation, Direction.north);
      expect(robot.flowersHeld, 0);
    });

    test('should check if robot has flowers', () {
      const robotWithFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robotWithoutFlowers = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      expect(robotWithFlowers.hasFlowers, true);
      expect(robotWithoutFlowers.hasFlowers, false);
    });

    test('should check if robot can pick more flowers', () {
      const robotCanPick = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robotFull = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 12,
      );

      expect(robotCanPick.canPickMore, true);
      expect(robotFull.canPickMore, false);
    });

    test('should create copy with updated fields', () {
      const original = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
        flowersHeld: 0,
      );

      final updated = original.copyWith(
        position: const Position(x: 1, y: 1),
        flowersHeld: 3,
      );

      expect(updated.position.x, 1);
      expect(updated.position.y, 1);
      expect(updated.flowersHeld, 3);
      expect(updated.orientation, Direction.north);
    });

    test('should serialize to JSON', () {
      const robot = Robot(
        position: Position(x: 2, y: 3),
        orientation: Direction.east,
        flowersHeld: 4,
      );

      final json = robot.toJson();

      expect(json['position']['x'], 2);
      expect(json['position']['y'], 3);
      expect(json['orientation'], 'east');
      expect(json['flowersHeld'], 4);
    });

    test('should deserialize from JSON', () {
      final json = {
        'position': {'x': 2, 'y': 3},
        'orientation': 'south',
        'flowersHeld': 7,
      };

      final robot = Robot.fromJson(json);

      expect(robot.position.x, 2);
      expect(robot.position.y, 3);
      expect(robot.orientation, Direction.south);
      expect(robot.flowersHeld, 7);
    });

    test('should maintain equality for same values', () {
      const robot1 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      const robot2 = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.north,
        flowersHeld: 5,
      );

      expect(robot1, robot2);
    });
  });
}
''',

        'test/unit/domain/entities/game_board_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/entities/cell.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/cell_type.dart';

void main() {
  group('GameBoard Entity', () {
    late GameBoard testBoard;

    setUp(() {
      testBoard = const GameBoard(
        width: 5,
        height: 5,
        cells: [
          Cell(position: Position(x: 0, y: 0), type: CellType.empty),
          Cell(position: Position(x: 1, y: 1), type: CellType.flower),
          Cell(position: Position(x: 2, y: 2), type: CellType.obstacle),
        ],
        robot: Robot(
          position: Position(x: 0, y: 0),
          orientation: Direction.north,
        ),
        princessPosition: Position(x: 4, y: 4),
        totalFlowers: 3,
        flowersDelivered: 0,
      );
    });

    test('should get cell at position', () {
      final cell = testBoard.getCellAt(const Position(x: 1, y: 1));
      expect(cell, isNotNull);
      expect(cell!.type, CellType.flower);
    });

    test('should return null for non-existent cell', () {
      final cell = testBoard.getCellAt(const Position(x: 10, y: 10));
      expect(cell, isNull);
    });

    test('should validate positions correctly', () {
      expect(testBoard.isValidPosition(const Position(x: 0, y: 0)), true);
      expect(testBoard.isValidPosition(const Position(x: 4, y: 4)), true);
      expect(testBoard.isValidPosition(const Position(x: 5, y: 5)), false);
      expect(testBoard.isValidPosition(const Position(x: -1, y: 0)), false);
      expect(testBoard.isValidPosition(const Position(x: 0, y: -1)), false);
    });

    test('should calculate remaining flowers', () {
      expect(testBoard.remainingFlowers, 3);

      final updatedBoard = testBoard.copyWith(flowersDelivered: 1);
      expect(updatedBoard.remainingFlowers, 2);
    });

    test('should check if board is complete', () {
      expect(testBoard.isComplete, false);

      final completeBoard = testBoard.copyWith(flowersDelivered: 3);
      expect(completeBoard.isComplete, true);

      final overCompleteBoard = testBoard.copyWith(flowersDelivered: 5);
      expect(overCompleteBoard.isComplete, true);
    });

    test('should serialize to JSON', () {
      final json = testBoard.toJson();

      expect(json['width'], 5);
      expect(json['height'], 5);
      expect(json['totalFlowers'], 3);
      expect(json['flowersDelivered'], 0);
      expect(json['cells'], isA<List>());
      expect(json['robot'], isA<Map>());
      expect(json['princessPosition'], isA<Map>());
    });

    test('should deserialize from JSON', () {
      final json = testBoard.toJson();
      final board = GameBoard.fromJson(json);

      expect(board.width, testBoard.width);
      expect(board.height, testBoard.height);
      expect(board.totalFlowers, testBoard.totalFlowers);
      expect(board.robot.position, testBoard.robot.position);
    });
  });
}
''',

        'test/unit/domain/entities/game_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

void main() {
  group('Game Entity', () {
    late Game testGame;

    setUp(() {
      testGame = Game(
        id: 'test-123',
        name: 'Test Game',
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
        status: GameStatus.playing,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('should create game with required fields', () {
      expect(testGame.id, 'test-123');
      expect(testGame.name, 'Test Game');
      expect(testGame.status, GameStatus.playing);
      expect(testGame.board.width, 10);
    });

    test('should have empty actions list by default', () {
      expect(testGame.actions, isEmpty);
    });

    test('should allow creating copy with modified fields', () {
      final updated = testGame.copyWith(
        name: 'Updated Game',
        status: GameStatus.won,
      );

      expect(updated.name, 'Updated Game');
      expect(updated.status, GameStatus.won);
      expect(updated.id, testGame.id);
    });

    test('should serialize to JSON', () {
      final json = testGame.toJson();

      expect(json['id'], 'test-123');
      expect(json['name'], 'Test Game');
      expect(json['status'], 'playing');
      expect(json['board'], isA<Map>());
      expect(json['createdAt'], isA<String>());
    });

    test('should deserialize from JSON', () {
      final json = testGame.toJson();
      final game = Game.fromJson(json);

      expect(game.id, testGame.id);
      expect(game.name, testGame.name);
      expect(game.status, testGame.status);
    });
  });
}
''',

        # Value Object Tests
        'test/unit/domain/value_objects/position_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';

void main() {
  group('Position Value Object', () {
    test('should create position with coordinates', () {
      const position = Position(x: 5, y: 10);

      expect(position.x, 5);
      expect(position.y, 10);
    });

    test('should support equality', () {
      const position1 = Position(x: 3, y: 4);
      const position2 = Position(x: 3, y: 4);
      const position3 = Position(x: 3, y: 5);

      expect(position1, position2);
      expect(position1 == position3, false);
    });

    test('should create copy with modified fields', () {
      const original = Position(x: 1, y: 2);
      final copy = original.copyWith(x: 5);

      expect(copy.x, 5);
      expect(copy.y, 2);
    });

    test('should serialize to JSON', () {
      const position = Position(x: 7, y: 8);
      final json = position.toJson();

      expect(json['x'], 7);
      expect(json['y'], 8);
    });

    test('should deserialize from JSON', () {
      final json = {'x': 3, 'y': 6};
      final position = Position.fromJson(json);

      expect(position.x, 3);
      expect(position.y, 6);
    });

    test('should have meaningful toString', () {
      const position = Position(x: 2, y: 3);
      expect(position.toString(), 'Position(x: 2, y: 3)');
    });
  });
}
''',

        'test/unit/domain/value_objects/direction_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

void main() {
  group('Direction Value Object', () {
    test('should have all four directions', () {
      expect(Direction.values.length, 4);
      expect(Direction.values, contains(Direction.north));
      expect(Direction.values, contains(Direction.east));
      expect(Direction.values, contains(Direction.south));
      expect(Direction.values, contains(Direction.west));
    });

    test('should have display names', () {
      expect(Direction.north.displayName, '⬆️ North');
      expect(Direction.east.displayName, '➡️ East');
      expect(Direction.south.displayName, '⬇️ South');
      expect(Direction.west.displayName, '⬅️ West');
    });

    test('should have icons', () {
      expect(Direction.north.icon, '⬆️');
      expect(Direction.east.icon, '➡️');
      expect(Direction.south.icon, '⬇️');
      expect(Direction.west.icon, '⬅️');
    });
  });
}
''',

        'test/unit/domain/value_objects/game_status_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';

void main() {
  group('GameStatus Value Object', () {
    test('should have all status types', () {
      expect(GameStatus.values.length, 3);
      expect(GameStatus.values, contains(GameStatus.playing));
      expect(GameStatus.values, contains(GameStatus.won));
      expect(GameStatus.values, contains(GameStatus.gameOver));
    });

    test('should have display names', () {
      expect(GameStatus.playing.displayName, '🎮 Playing');
      expect(GameStatus.won.displayName, '🏆 Won');
      expect(GameStatus.gameOver.displayName, '💀 Game Over');
    });

    test('should correctly identify finished status', () {
      expect(GameStatus.playing.isFinished, false);
      expect(GameStatus.won.isFinished, true);
      expect(GameStatus.gameOver.isFinished, true);
    });
  });
}
''',

        # Use Case Tests
        'test/unit/domain/use_cases/create_game_impl_test.dart': '''import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

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
      princessPosition: Position(x: 9, y: 9),
      totalFlowers: 5,
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

      expect(result, const Left(ValidationFailure('Game name cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when board size is too small', () async {
      final result = await useCase('Test Game', 2);

      expect(
        result,
        const Left(ValidationFailure('Board size must be between 3 and 50')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when board size is too large', () async {
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
''',

        'test/unit/domain/use_cases/get_games_impl_test.dart': '''import 'package:dartz/dartz.dart';
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
      when(mockRepository.getGames())
          .thenAnswer((_) async => Right(testGames));

      final result = await useCase();

      expect(result, Right(testGames));
      expect((result as Right).value.length, 2);
      verify(mockRepository.getGames());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no games exist', () async {
      when(mockRepository.getGames())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase();

      expect(result, const Right([]));
      verify(mockRepository.getGames());
    });

    test('should return ServerFailure when repository fails', () async {
      when(mockRepository.getGames())
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      final result = await useCase();

      expect(result, const Left(ServerFailure('Server error')));
      verify(mockRepository.getGames());
    });
  });
}
''',

        'test/unit/domain/use_cases/execute_action_impl_test.dart': '''import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';

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
        flowersHeld: 2,
      ),
      princessPosition: Position(x: 4, y: 4),
      totalFlowers: 3,
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
''',
    }

    for file_path, content in files.items():
        full_path = os.path.join(base_path, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)

def main():
    """Main function to generate Part 2B"""
    base_path = 'robot-flower-princess-front'

    print("🚀 Generating Part 2B: Domain Layer Tests...")

    # Create directory structure
    create_directory_structure(base_path)
    print("✅ Test directory structure created")

    # Generate files
    generate_files(base_path)
    print("✅ Domain test files generated")

    # Create zip file
    zip_filename = 'robot-flower-princess-part2b.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            # Only include domain test files
            if 'test/unit/domain' in root:
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                    zipf.write(file_path, arcname)

    print(f"✅ Part 2B packaged as {zip_filename}")
    print("\n📦 Part 2B Complete!")
    print("   ✅ Entity tests (Robot, GameBoard, Game)")
    print("   ✅ Value object tests (Position, Direction, GameStatus)")
    print("   ✅ Use case tests (CreateGame, GetGames, ExecuteAction)")
    print("   ✅ Mock files for testing")
    print("\n📝 Note: Run 'flutter pub run build_runner build' to generate mock files")

if __name__ == '__main__':
    main()