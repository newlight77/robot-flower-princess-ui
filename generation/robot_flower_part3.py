#!/usr/bin/env python3
"""
Robot Flower Princess - Part 3: Data & Presentation Layer
Generates repositories, datasources, models, providers, and widgets
"""

import os
import zipfile
from pathlib import Path

def generate_files(base_path):
    """Generate all data and presentation layer files"""

    files = {
        # Data Models
        'lib/data/models/game_model.dart': '''import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_action.dart';
import '../../domain/value_objects/game_status.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.board,
    required super.status,
    super.actions,
    required super.createdAt,
    super.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
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

  @override
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

  Game toEntity() {
    return Game(
      id: id,
      name: name,
      board: board,
      status: status,
      actions: actions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
''',

        # Data Sources
        'lib/data/datasources/game_remote_datasource.dart': '''import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import '../models/game_model.dart';

abstract class GameRemoteDataSource {
  Future<GameModel> createGame(String name, int boardSize);
  Future<List<GameModel>> getGames();
  Future<GameModel> getGame(String gameId);
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<GameModel> autoPlay(String gameId);
  Future<List<Map<String, dynamic>>> replayGame(String gameId);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final ApiClient client;

  GameRemoteDataSourceImpl(this.client);

  @override
  Future<GameModel> createGame(String name, int boardSize) async {
    try {
      final response = await client.post(
        ApiEndpoints.games,
        data: {
          'name': name,
          'boardSize': boardSize,
        },
      );
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<GameModel>> getGames() async {
    try {
      final response = await client.get(ApiEndpoints.games);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> getGame(String gameId) async {
    try {
      final response = await client.get(ApiEndpoints.game(gameId));
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    try {
      final response = await client.post(
        ApiEndpoints.gameAction(gameId),
        data: {
          'action': action.name,
          'direction': direction.name,
        },
      );
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> autoPlay(String gameId) async {
    try {
      final response = await client.post(ApiEndpoints.autoPlay(gameId));
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> replayGame(String gameId) async {
    try {
      final response = await client.get(ApiEndpoints.replay(gameId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['message'] ?? e.message;

      if (statusCode == 404) {
        return NotFoundException(message);
      } else if (statusCode == 400) {
        return ValidationException(message);
      } else if (statusCode == 500) {
        return ServerException(message);
      }
    }
    return NetworkException(e.message ?? 'Network error occurred');
  }
}
''',

        # Repository Implementation
        'lib/data/repositories/game_repository_impl.dart': '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import '../datasources/game_remote_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Game>> createGame(String name, int boardSize) async {
    try {
      final gameModel = await remoteDataSource.createGame(name, boardSize);
      return Right(gameModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGames() async {
    try {
      final gameModels = await remoteDataSource.getGames();
      return Right(gameModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> getGame(String gameId) async {
    try {
      final gameModel = await remoteDataSource.getGame(gameId);
      return Right(gameModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    try {
      final gameModel = await remoteDataSource.executeAction(
        gameId,
        action,
        direction,
      );
      return Right(gameModel.toEntity());
    } on GameOverException catch (e) {
      return Left(GameOverFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> autoPlay(String gameId) async {
    try {
      final gameModel = await remoteDataSource.autoPlay(gameId);
      return Right(gameModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId) async {
    try {
      final boardStates = await remoteDataSource.replayGame(gameId);
      final boards = boardStates
          .map((json) => GameBoard.fromJson(json))
          .toList();
      return Right(boards);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''',

        # Providers
        'lib/presentation/providers/game_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/game_remote_datasource.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/use_cases/create_game_impl.dart';
import '../../domain/use_cases/get_games_impl.dart';
import '../../domain/use_cases/get_game_impl.dart';
import '../../domain/use_cases/execute_action_impl.dart';
import '../../domain/use_cases/auto_play_impl.dart';
import '../../domain/use_cases/replay_game_impl.dart';

// Infrastructure
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final gameRemoteDataSourceProvider = Provider<GameRemoteDataSource>(
  (ref) => GameRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(gameRemoteDataSourceProvider)),
);

// Use Cases
final createGameUseCaseProvider = Provider(
  (ref) => CreateGameImpl(ref.watch(gameRepositoryProvider)),
);

final getGamesUseCaseProvider = Provider(
  (ref) => GetGamesImpl(ref.watch(gameRepositoryProvider)),
);

final getGameUseCaseProvider = Provider(
  (ref) => GetGameImpl(ref.watch(gameRepositoryProvider)),
);

final executeActionUseCaseProvider = Provider(
  (ref) => ExecuteActionImpl(ref.watch(gameRepositoryProvider)),
);

final autoPlayUseCaseProvider = Provider(
  (ref) => AutoPlayImpl(ref.watch(gameRepositoryProvider)),
);

final replayGameUseCaseProvider = Provider(
  (ref) => ReplayGameImpl(ref.watch(gameRepositoryProvider)),
);
''',

        'lib/presentation/providers/games_list_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game.dart';
import 'game_provider.dart';

class GamesListNotifier extends StateNotifier<AsyncValue<List<Game>>> {
  GamesListNotifier(this._getGamesUseCase) : super(const AsyncValue.loading());

  final dynamic _getGamesUseCase;

  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    final result = await _getGamesUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (games) => state = AsyncValue.data(games),
    );
  }

  void addGame(Game game) {
    state.whenData((games) {
      state = AsyncValue.data([game, ...games]);
    });
  }
}

final gamesListProvider =
    StateNotifierProvider<GamesListNotifier, AsyncValue<List<Game>>>((ref) {
  return GamesListNotifier(ref.watch(getGamesUseCaseProvider));
});
''',

        'lib/presentation/providers/current_game_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import 'game_provider.dart';

class CurrentGameNotifier extends StateNotifier<AsyncValue<Game?>> {
  CurrentGameNotifier(
    this._getGameUseCase,
    this._executeActionUseCase,
    this._autoPlayUseCase,
  ) : super(const AsyncValue.data(null));

  final dynamic _getGameUseCase;
  final dynamic _executeActionUseCase;
  final dynamic _autoPlayUseCase;

  Future<void> loadGame(String gameId) async {
    state = const AsyncValue.loading();
    final result = await _getGameUseCase(gameId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  Future<void> executeAction(ActionType action, Direction direction) async {
    final currentGame = state.value;
    if (currentGame == null) return;

    state = const AsyncValue.loading();
    final result = await _executeActionUseCase(currentGame.id, action, direction);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  Future<void> autoPlay() async {
    final currentGame = state.value;
    if (currentGame == null) return;

    state = const AsyncValue.loading();
    final result = await _autoPlayUseCase(currentGame.id);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  void clearGame() {
    state = const AsyncValue.data(null);
  }
}

final currentGameProvider =
    StateNotifierProvider<CurrentGameNotifier, AsyncValue<Game?>>((ref) {
  return CurrentGameNotifier(
    ref.watch(getGameUseCaseProvider),
    ref.watch(executeActionUseCaseProvider),
    ref.watch(autoPlayUseCaseProvider),
  );
});
''',

        # Widgets
        'lib/presentation/widgets/game_board_widget.dart': '''import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/value_objects/cell_type.dart';
import '../../domain/value_objects/position.dart';

class GameBoardWidget extends StatelessWidget {
  final GameBoard board;
  final double cellSize;

  const GameBoardWidget({
    super.key,
    required this.board,
    this.cellSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final calculatedCellSize = (availableWidth / board.width).clamp(20.0, 60.0);
        final boardWidth = calculatedCellSize * board.width;
        final boardHeight = calculatedCellSize * board.height;

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Container(
                width: boardWidth,
                height: boardHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.forestGreen, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: board.width,
                  ),
                  itemCount: board.width * board.height,
                  itemBuilder: (context, index) {
                    final x = index % board.width;
                    final y = index ~/ board.width;
                    final position = Position(x: x, y: y);
                    final cell = board.getCellAt(position);

                    return _buildCell(context, cell, position);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, Cell? cell, Position position) {
    final isRobotHere = board.robot.position == position;
    final isPrincessHere = board.princessPosition == position;

    Color backgroundColor = AppColors.emptyCell;
    String icon = CellType.empty.icon;

    if (isRobotHere) {
      backgroundColor = AppColors.robotBlue.withOpacity(0.3);
      icon = '🤖';
    } else if (isPrincessHere) {
      backgroundColor = AppColors.princessPink.withOpacity(0.3);
      icon = '👑';
    } else if (cell != null) {
      switch (cell.type) {
        case CellType.flower:
          backgroundColor = AppColors.flowerPink.withOpacity(0.3);
          icon = '🌸';
          break;
        case CellType.obstacle:
          backgroundColor = AppColors.obstacleGray.withOpacity(0.3);
          icon = '🗑️';
          break;
        default:
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: AppColors.mossGreen.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
''',

        'lib/presentation/widgets/action_button.dart': '''import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/value_objects/action_type.dart';

class ActionButton extends StatelessWidget {
  final ActionType actionType;
  final VoidCallback onPressed;
  final bool isEnabled;

  const ActionButton({
    super.key,
    required this.actionType,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: actionType.displayName,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.forestGreen : AppColors.obstacleGray,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionType.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              actionType.displayName.split(' ').last,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
''',

        'lib/presentation/widgets/direction_selector.dart': '''import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/value_objects/direction.dart';

class DirectionSelector extends StatelessWidget {
  final Direction? selectedDirection;
  final ValueChanged<Direction> onDirectionSelected;

  const DirectionSelector({
    super.key,
    required this.selectedDirection,
    required this.onDirectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Direction',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(Direction.NORTH),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.EAST),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.SOUTH),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.WEST),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(Direction direction) {
    final isSelected = selectedDirection == direction;

    return ElevatedButton(
      onPressed: () => onDirectionSelected(direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.warmOrange : AppColors.mossGreen,
        padding: const EdgeInsets.all(12),
        shape: const CircleBorder(),
      ),
      child: Text(
        direction.icon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
''',

        'lib/presentation/widgets/game_status_badge.dart': '''import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/value_objects/game_status.dart';

class GameStatusBadge extends StatelessWidget {
  final GameStatus status;

  const GameStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    switch (status) {
      case GameStatus.playing:
        backgroundColor = AppColors.info;
        break;
      case GameStatus.won:
        backgroundColor = AppColors.success;
        break;
      case GameStatus.gameOver:
        backgroundColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
''',

        'lib/presentation/widgets/game_info_panel.dart': '''import 'package:flutter/material.dart';
import '../../domain/entities/game.dart';
import 'game_status_badge.dart';

class GameInfoPanel extends StatelessWidget {
  final Game game;

  const GameInfoPanel({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GameStatusBadge(status: game.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '🤖 Robot Position',
              '(${game.board.robot.position.x}, ${game.board.robot.position.y})',
            ),
            _buildInfoRow(
              '🌸 Flowers Held',
              '${game.board.robot.flowersHeld}/12',
            ),
            _buildInfoRow(
              '📦 Total Flowers',
              '${game.board.totalFlowers}',
            ),
            _buildInfoRow(
              '✅ Flowers Delivered',
              '${game.board.flowersDelivered}',
            ),
            _buildInfoRow(
              '⏱️ Actions Taken',
              '${game.actions.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
''',

        # Tests
        'test/unit/data/repositories/game_repository_impl_test.dart': '''import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/exceptions.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/data/datasources/game_remote_datasource.dart';
import 'package:robot_flower_princess_front/data/models/game_model.dart';
import 'package:robot_flower_princess_front/data/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([GameRemoteDataSource])
import 'game_repository_impl_test.mocks.dart';

void main() {
  late GameRepositoryImpl repository;
  late MockGameRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockGameRemoteDataSource();
    repository = GameRepositoryImpl(mockDataSource);
  });

  final testGameModel = GameModel(
    id: '1',
    name: 'Test Game',
    board: const GameBoard(
      width: 10,
      height: 10,
      cells: [],
      robot: Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      ),
      princessPosition: Position(x: 9, y: 9),
      totalFlowers: 5,
    ),
    status: GameStatus.playing,
    createdAt: DateTime.now(),
  );

  group('createGame', () {
    test('should return Game when datasource call is successful', () async {
      when(mockDataSource.createGame(any, any))
          .thenAnswer((_) async => testGameModel);

      final result = await repository.createGame('Test Game', 10);

      expect(result.isRight(), true);
      verify(mockDataSource.createGame('Test Game', 10));
    });

    test('should return ServerFailure when datasource throws ServerException',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.createGame('Test Game', 10);

      expect(result, const Left(ServerFailure('Server error')));
    });

    test('should return NetworkFailure when datasource throws NetworkException',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.createGame('Test Game', 10);

      expect(result, const Left(NetworkFailure('Network error')));
    });
  });

  group('getGames', () {
    test('should return list of Games when datasource call is successful',
        () async {
      when(mockDataSource.getGames())
          .thenAnswer((_) async => [testGameModel]);

      final result = await repository.getGames();

      expect(result.isRight(), true);
      verify(mockDataSource.getGames());
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
    """Main function to generate Part 3"""
    base_path = 'robot-flower-princess-front'

    print("🚀 Generating Part 3: Data & Presentation Layer...")

    # Generate files
    generate_files(base_path)
    print("✅ Data & Presentation layer files generated")

    # Create zip file
    zip_filename = 'robot-flower-princess-part3.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            if 'data' in root or 'presentation' in root or 'test/unit/data' in root:
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                    zipf.write(file_path, arcname)

    print(f"✅ Part 3 packaged as {zip_filename}")
    print("\n📦 Part 3 Complete!")
    print("   - Data models created")
    print("   - Remote datasource implemented")
    print("   - Repository implementation added")
    print("   - Riverpod providers configured")
    print("   - Reusable widgets created")
    print("   - Repository tests added")

if __name__ == '__main__':
    main()