import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_action.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/princess.dart';
import '../../domain/entities/robot.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/cell_type.dart';
import '../../domain/value_objects/direction.dart';
import '../../domain/value_objects/game_status.dart';
import '../../domain/value_objects/position.dart';
import '../models/game_model.dart';

class GameMockDataSource {
  final _uuid = const Uuid();
  final _random = Random();
  final List<GameModel> _games = [];

  Future<GameModel> createGame(String name, int boardSize) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final gameId = _uuid.v4();
    final board = _generateBoard(boardSize);

    final game = GameModel(
      id: gameId,
      name: name,
      board: board,
      status: GameStatus.playing,
      createdAt: DateTime.now(),
    );

    _games.add(game);
    return game;
  }

  Future<List<GameModel>> getGames({int limit = 10, String? status}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    var filteredGames = _games;
    if (status != null) {
      filteredGames = _games.where((game) {
        if (status == 'in_progress') {
          return game.status == GameStatus.playing;
        } else if (status == 'victory') {
          return game.status == GameStatus.won;
        } else if (status == 'game_over') {
          return game.status == GameStatus.gameOver;
        }
        return true;
      }).toList();
    }

    return filteredGames.take(limit).toList();
  }

  Future<GameModel> getGame(String gameId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final game = _games.firstWhere(
      (game) => game.id == gameId,
      orElse: () => throw Exception('Game not found'),
    );

    return game;
  }

  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final gameIndex = _games.indexWhere((game) => game.id == gameId);
    if (gameIndex == -1) {
      throw Exception('Game not found');
    }

    final game = _games[gameIndex];
    final updatedGame = _simulateAction(game, action, direction);
    _games[gameIndex] = updatedGame;

    return updatedGame;
  }

  Future<GameModel> autoPlay(String gameId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final gameIndex = _games.indexWhere((game) => game.id == gameId);
    if (gameIndex == -1) {
      throw Exception('Game not found');
    }

    final game = _games[gameIndex];
    final updatedGame = _simulateAutoPlay(game);
    _games[gameIndex] = updatedGame;

    return updatedGame;
  }

  Future<Map<String, dynamic>> getGameHistory(String gameId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final game = _games.firstWhere(
      (game) => game.id == gameId,
      orElse: () => throw Exception('Game not found'),
    );

    // Return history response matching the API format
    return {
      'id': gameId,
      'history': [game.board.toJson()],
    };
  }

  GameBoard _generateBoard(int size) {
    final cells = <Cell>[];
    final robot = const Robot(
      position: Position(x: 0, y: 0),
      orientation: Direction.north,
    );

    // Place princess at the opposite corner
    final princessPosition = Position(x: size - 1, y: size - 1);

    // Generate cells
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final position = Position(x: x, y: y);

        // Skip robot and princess positions
        if (position == robot.position || position == princessPosition) {
          cells.add(Cell(position: position, type: CellType.empty));
          continue;
        }

        // Randomly place flowers and obstacles
        final cellType = _getRandomCellType();
        cells.add(Cell(position: position, type: cellType));
      }
    }

    // Count flowers and obstacles
    final flowersRemaining = cells.where((cell) => cell.type == CellType.flower).length;
    final totalObstacles = cells.where((cell) => cell.type == CellType.obstacle).length;

    return GameBoard(
      width: size,
      height: size,
      cells: cells,
      robot: robot,
      princess: Princess(position: princessPosition),
      flowersRemaining: flowersRemaining,
      totalObstacles: totalObstacles,
      obstaclesRemaining: totalObstacles,
    );
  }

  CellType _getRandomCellType() {
    final rand = _random.nextDouble();
    if (rand < 0.1) {
      return CellType.flower;
    } else if (rand < 0.4) {
      return CellType.obstacle;
    }
    return CellType.empty;
  }

  GameModel _simulateAction(GameModel game, ActionType action, Direction direction) {
    // Simple simulation - just add the action to the game
    final newAction = GameAction(
      type: action,
      direction: direction,
      timestamp: DateTime.now(),
      success: true,
    );

    final updatedActions = List<GameAction>.from(game.actions)..add(newAction);

    return GameModel(
      id: game.id,
      name: game.name,
      board: game.board,
      status: game.status,
      actions: updatedActions,
      createdAt: game.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  GameModel _simulateAutoPlay(GameModel game) {
    // Simple auto-play simulation - just mark as won
    final updatedActions = List<GameAction>.from(game.actions);

    // Add some simulated actions
    for (int i = 0; i < 5; i++) {
      updatedActions.add(GameAction(
        type: ActionType.move,
        direction: Direction.values[_random.nextInt(Direction.values.length)],
        timestamp: DateTime.now().add(Duration(seconds: i)),
        success: true,
      ));
    }

    return GameModel(
      id: game.id,
      name: game.name,
      board: game.board,
      status: GameStatus.won,
      actions: updatedActions,
      createdAt: game.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
