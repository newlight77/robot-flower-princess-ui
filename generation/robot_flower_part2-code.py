#!/usr/bin/env python3
"""
Robot Flower Princess - Part 2A: Domain Layer (Production Code)
Generates entities, value objects, ports, and use cases
"""

import os
import zipfile
from pathlib import Path

def create_directory_structure(base_path):
    """Create the domain layer directory structure"""
    directories = [
        'lib/domain/entities',
        'lib/domain/value_objects',
        'lib/domain/ports/inbound',
        'lib/domain/ports/outbound',
        'lib/domain/use_cases',
    ]

    for directory in directories:
        Path(os.path.join(base_path, directory)).mkdir(parents=True, exist_ok=True)

def generate_files(base_path):
    """Generate all domain layer files"""

    files = {
        # Value Objects
        'lib/domain/value_objects/position.dart': '''import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int x;
  final int y;

  const Position({required this.x, required this.y});

  Position copyWith({int? x, int? y}) {
    return Position(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  List<Object> get props => [x, y];

  @override
  String toString() => 'Position(x: $x, y: $y)';

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'] as int,
      y: json['y'] as int,
    );
  }
}
''',

        'lib/domain/value_objects/direction.dart': '''enum Direction {
  NORTH,
  EAST,
  SOUTH,
  WEST;

  String get displayName {
    switch (this) {
      case Direction.NORTH:
        return '⬆️ NORTH';
      case Direction.EAST:
        return '➡️ EAST';
      case Direction.SOUTH:
        return '⬇️ SOUTH';
      case Direction.WEST:
        return '⬅️ WEST';
    }
  }

  String get icon {
    switch (this) {
      case Direction.NORTH:
        return '⬆️';
      case Direction.EAST:
        return '➡️';
      case Direction.SOUTH:
        return '⬇️';
      case Direction.WEST:
        return '⬅️';
    }
  }
}
''',

        'lib/domain/value_objects/cell_type.dart': '''enum CellType {
  empty,
  robot,
  princess,
  flower,
  obstacle;

  String get displayName {
    switch (this) {
      case CellType.empty:
        return 'Empty';
      case CellType.robot:
        return 'Robot';
      case CellType.princess:
        return 'Princess';
      case CellType.flower:
        return 'Flower';
      case CellType.obstacle:
        return 'Obstacle';
    }
  }

  String get icon {
    switch (this) {
      case CellType.empty:
        return '⬜';
      case CellType.robot:
        return '🤖';
      case CellType.princess:
        return '👑';
      case CellType.flower:
        return '🌸';
      case CellType.obstacle:
        return '🗑️';
    }
  }
}
''',

        'lib/domain/value_objects/game_status.dart': '''enum GameStatus {
  playing,
  won,
  gameOver;

  String get displayName {
    switch (this) {
      case GameStatus.playing:
        return '🎮 Playing';
      case GameStatus.won:
        return '🏆 Won';
      case GameStatus.gameOver:
        return '💀 Game Over';
    }
  }

  bool get isFinished => this == GameStatus.won || this == GameStatus.gameOver;
}
''',

        'lib/domain/value_objects/action_type.dart': '''enum ActionType {
  rotate,
  move,
  pickFlower,
  dropFlower,
  giveFlower,
  clean;

  String get displayName {
    switch (this) {
      case ActionType.rotate:
        return '↩️ Rotate';
      case ActionType.move:
        return '🚶 Move';
      case ActionType.pickFlower:
        return '⛏️ Pick Flower';
      case ActionType.dropFlower:
        return '🫳 Drop Flower';
      case ActionType.giveFlower:
        return '🫴 Give Flower';
      case ActionType.clean:
        return '🗑️ Clean';
    }
  }

  String get icon {
    switch (this) {
      case ActionType.rotate:
        return '↩️';
      case ActionType.move:
        return '🚶';
      case ActionType.pickFlower:
        return '⛏️';
      case ActionType.dropFlower:
        return '🫳';
      case ActionType.giveFlower:
        return '🫴';
      case ActionType.clean:
        return '🗑️';
    }
  }
}
''',

        # Entities
        'lib/domain/entities/cell.dart': '''import 'package:equatable/equatable.dart';
import '../value_objects/position.dart';
import '../value_objects/cell_type.dart';

class Cell extends Equatable {
  final Position position;
  final CellType type;

  const Cell({
    required this.position,
    required this.type,
  });

  Cell copyWith({
    Position? position,
    CellType? type,
  }) {
    return Cell(
      position: position ?? this.position,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [position, type];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'type': type.name,
    };
  }

  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      type: CellType.values.firstWhere((e) => e.name == json['type']),
    );
  }
}
''',

        'lib/domain/entities/robot.dart': '''import 'package:equatable/equatable.dart';
import '../value_objects/position.dart';
import '../value_objects/direction.dart';

class Robot extends Equatable {
  final Position position;
  final Direction orientation;
  final int flowersHeld;

  const Robot({
    required this.position,
    required this.orientation,
    this.flowersHeld = 0,
  });

  Robot copyWith({
    Position? position,
    Direction? orientation,
    int? flowersHeld,
  }) {
    return Robot(
      position: position ?? this.position,
      orientation: orientation ?? this.orientation,
      flowersHeld: flowersHeld ?? this.flowersHeld,
    );
  }

  bool get hasFlowers => flowersHeld > 0;
  bool get canPickMore => flowersHeld < 12;

  @override
  List<Object> get props => [position, orientation, flowersHeld];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'orientation': orientation.name,
      'flowersHeld': flowersHeld,
    };
  }

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      orientation: Direction.values.firstWhere((e) => e.name == json['orientation']),
      flowersHeld: json['flowersHeld'] as int? ?? 0,
    );
  }
}
''',

        'lib/domain/entities/game_board.dart': '''import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'robot.dart';
import '../value_objects/position.dart';

class GameBoard extends Equatable {
  final int width;
  final int height;
  final List<Cell> cells;
  final Robot robot;
  final Position princessPosition;
  final int totalFlowers;
  final int flowersDelivered;

  const GameBoard({
    required this.width,
    required this.height,
    required this.cells,
    required this.robot,
    required this.princessPosition,
    required this.totalFlowers,
    this.flowersDelivered = 0,
  });

  Cell? getCellAt(Position position) {
    try {
      return cells.firstWhere(
        (cell) => cell.position.x == position.x && cell.position.y == position.y,
      );
    } catch (e) {
      return null;
    }
  }

  bool isValidPosition(Position position) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  int get remainingFlowers => totalFlowers - flowersDelivered;
  bool get isComplete => flowersDelivered >= totalFlowers;

  GameBoard copyWith({
    int? width,
    int? height,
    List<Cell>? cells,
    Robot? robot,
    Position? princessPosition,
    int? totalFlowers,
    int? flowersDelivered,
  }) {
    return GameBoard(
      width: width ?? this.width,
      height: height ?? this.height,
      cells: cells ?? this.cells,
      robot: robot ?? this.robot,
      princessPosition: princessPosition ?? this.princessPosition,
      totalFlowers: totalFlowers ?? this.totalFlowers,
      flowersDelivered: flowersDelivered ?? this.flowersDelivered,
    );
  }

  @override
  List<Object> get props => [
        width,
        height,
        cells,
        robot,
        princessPosition,
        totalFlowers,
        flowersDelivered,
      ];

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'cells': cells.map((c) => c.toJson()).toList(),
      'robot': robot.toJson(),
      'princessPosition': princessPosition.toJson(),
      'totalFlowers': totalFlowers,
      'flowersDelivered': flowersDelivered,
    };
  }

  factory GameBoard.fromJson(Map<String, dynamic> json) {
    return GameBoard(
      width: json['width'] as int,
      height: json['height'] as int,
      cells: (json['cells'] as List)
          .map((c) => Cell.fromJson(c as Map<String, dynamic>))
          .toList(),
      robot: Robot.fromJson(json['robot'] as Map<String, dynamic>),
      princessPosition: Position.fromJson(
        json['princessPosition'] as Map<String, dynamic>,
      ),
      totalFlowers: json['totalFlowers'] as int,
      flowersDelivered: json['flowersDelivered'] as int? ?? 0,
    );
  }
}
''',

        'lib/domain/entities/game_action.dart': '''import 'package:equatable/equatable.dart';
import '../value_objects/action_type.dart';
import '../value_objects/direction.dart';

class GameAction extends Equatable {
  final ActionType type;
  final Direction direction;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;

  const GameAction({
    required this.type,
    required this.direction,
    required this.timestamp,
    this.success = true,
    this.errorMessage,
  });

  GameAction copyWith({
    ActionType? type,
    Direction? direction,
    DateTime? timestamp,
    bool? success,
    String? errorMessage,
  }) {
    return GameAction(
      type: type ?? this.type,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [type, direction, timestamp, success, errorMessage];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'direction': direction.name,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  factory GameAction.fromJson(Map<String, dynamic> json) {
    return GameAction(
      type: ActionType.values.firstWhere((e) => e.name == json['type']),
      direction: Direction.values.firstWhere((e) => e.name == json['direction']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
''',

        'lib/domain/entities/game.dart': '''import 'package:equatable/equatable.dart';
import 'game_board.dart';
import 'game_action.dart';
import '../value_objects/game_status.dart';

class Game extends Equatable {
  final String id;
  final String name;
  final GameBoard board;
  final GameStatus status;
  final List<GameAction> actions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Game({
    required this.id,
    required this.name,
    required this.board,
    required this.status,
    this.actions = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Game copyWith({
    String? id,
    String? name,
    GameBoard? board,
    GameStatus? status,
    List<GameAction>? actions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      board: board ?? this.board,
      status: status ?? this.status,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        board,
        status,
        actions,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'board': board.toJson(),
      'status': status.name,
      'actions': actions.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      board: GameBoard.fromJson(json['board'] as Map<String, dynamic>),
      status: GameStatus.values.firstWhere((e) => e.name == json['status']),
      actions: (json['actions'] as List?)
              ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
''',

        # Ports - Inbound (Use Case Interfaces)
        'lib/domain/ports/inbound/create_game_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class CreateGameUseCase {
  Future<Either<Failure, Game>> call(String name, int boardSize);
}
''',

        'lib/domain/ports/inbound/get_games_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class GetGamesUseCase {
  Future<Either<Failure, List<Game>>> call();
}
''',

        'lib/domain/ports/inbound/get_game_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class GetGameUseCase {
  Future<Either<Failure, Game>> call(String gameId);
}
''',

        'lib/domain/ports/inbound/execute_action_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../value_objects/action_type.dart';
import '../../value_objects/direction.dart';

abstract class ExecuteActionUseCase {
  Future<Either<Failure, Game>> call(
    String gameId,
    ActionType action,
    Direction direction,
  );
}
''',

        'lib/domain/ports/inbound/auto_play_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class AutoPlayUseCase {
  Future<Either<Failure, Game>> call(String gameId);
}
''',

        'lib/domain/ports/inbound/replay_game_use_case.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game_board.dart';

abstract class ReplayGameUseCase {
  Future<Either<Failure, List<GameBoard>>> call(String gameId);
}
''',

        # Ports - Outbound (Repository Interfaces)
        'lib/domain/ports/outbound/game_repository.dart': '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../entities/game_board.dart';
import '../../value_objects/action_type.dart';
import '../../value_objects/direction.dart';

abstract class GameRepository {
  Future<Either<Failure, Game>> createGame(String name, int boardSize);
  Future<Either<Failure, List<Game>>> getGames();
  Future<Either<Failure, Game>> getGame(String gameId);
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<Either<Failure, Game>> autoPlay(String gameId);
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId);
}
''',

        # Use Cases Implementations
        'lib/domain/use_cases/create_game_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/create_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class CreateGameImpl implements CreateGameUseCase {
  final GameRepository repository;

  CreateGameImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String name, int boardSize) async {
    if (name.isEmpty) {
      return const Left(ValidationFailure('Game name cannot be empty'));
    }
    if (boardSize < 3 || boardSize > 50) {
      return const Left(ValidationFailure('Board size must be between 3 and 50'));
    }
    return await repository.createGame(name, boardSize);
  }
}
''',

        'lib/domain/use_cases/get_games_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/get_games_use_case.dart';
import '../ports/outbound/game_repository.dart';

class GetGamesImpl implements GetGamesUseCase {
  final GameRepository repository;

  GetGamesImpl(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call() async {
    return await repository.getGames();
  }
}
''',

        'lib/domain/use_cases/get_game_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/get_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class GetGameImpl implements GetGameUseCase {
  final GameRepository repository;

  GetGameImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.getGame(gameId);
  }
}
''',

        'lib/domain/use_cases/execute_action_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/execute_action_use_case.dart';
import '../ports/outbound/game_repository.dart';
import '../value_objects/action_type.dart';
import '../value_objects/direction.dart';

class ExecuteActionImpl implements ExecuteActionUseCase {
  final GameRepository repository;

  ExecuteActionImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.executeAction(gameId, action, direction);
  }
}
''',

        'lib/domain/use_cases/auto_play_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/auto_play_use_case.dart';
import '../ports/outbound/game_repository.dart';

class AutoPlayImpl implements AutoPlayUseCase {
  final GameRepository repository;

  AutoPlayImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.autoPlay(gameId);
  }
}
''',

        'lib/domain/use_cases/replay_game_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game_board.dart';
import '../ports/inbound/replay_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class ReplayGameImpl implements ReplayGameUseCase {
  final GameRepository repository;

  ReplayGameImpl(this.repository);

  @override
  Future<Either<Failure, List<GameBoard>>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.replayGame(gameId);
  }
}
''',
    }

    for file_path, content in files.items():
        full_path = os.path.join(base_path, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)

def main():
    """Main function to generate Part 2A"""
    base_path = 'robot-flower-princess-front'

    print("🚀 Generating Part 2A: Domain Layer (Production Code)...")

    # Create directory structure
    create_directory_structure(base_path)
    print("✅ Directory structure created")

    # Generate files
    generate_files(base_path)
    print("✅ Domain layer files generated")

    # Create zip file
    zip_filename = 'robot-flower-princess-part2a.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            # Only include domain files
            if 'lib/domain' in root:
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                    zipf.write(file_path, arcname)

    print(f"✅ Part 2A packaged as {zip_filename}")
    print("\n📦 Part 2A Complete!")
    print("   ✅ Value objects (Position, Direction, CellType, GameStatus, ActionType)")
    print("   ✅ Entities (Game, Robot, GameBoard, Cell, GameAction)")
    print("   ✅ Ports - Inbound (Use case interfaces)")
    print("   ✅ Ports - Outbound (Repository interfaces)")
    print("   ✅ Use cases implementations (6 use cases)")
    print("\n📝 Next: Run Part 2B to generate domain tests")

if __name__ == '__main__':
    main()