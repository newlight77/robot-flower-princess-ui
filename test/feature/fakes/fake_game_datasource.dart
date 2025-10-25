import 'package:robot_flower_princess_front/data/datasources/game_remote_datasource.dart';
import 'package:robot_flower_princess_front/data/models/game_model.dart';
import 'package:robot_flower_princess_front/domain/entities/cell.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/cell_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';

/// Fake implementation of GameRemoteDataSource for feature testing
/// This simulates backend behavior without making real HTTP calls
class FakeGameDataSource implements GameRemoteDataSource {
  final Map<String, GameModel> _games = {};
  int _gameCounter = 0;

  @override
  Future<GameModel> createGame(
    String name,
    int boardSize,
  ) async {
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate network delay

    final gameId = 'fake-game-${_gameCounter++}';

    // Generate a simple board
    const robot = Robot(
      position: Position(x: 0, y: 0),
      orientation: Direction.north,
      collectedFlowers: [],
      deliveredFlowers: [],
      cleanedObstacles: [],
    );

    final princess = Princess(
      position: Position(x: boardSize - 1, y: boardSize - 1),
      flowersReceived: 0,
    );

    // Create some flowers and obstacles
    final cells = <Cell>[
      const Cell(position: Position(x: 0, y: 0), type: CellType.robot),
      const Cell(position: Position(x: 1, y: 1), type: CellType.flower),
      const Cell(position: Position(x: 2, y: 2), type: CellType.flower),
      const Cell(position: Position(x: 3, y: 3), type: CellType.obstacle),
      const Cell(position: Position(x: 4, y: 4), type: CellType.obstacle),
      Cell(
          position: Position(x: boardSize - 1, y: boardSize - 1),
          type: CellType.princess),
    ];

    final board = GameBoard(
      width: boardSize,
      height: boardSize,
      cells: cells,
      robot: robot,
      princess: princess,
      flowersRemaining: 2,
      totalObstacles: 2,
      obstaclesRemaining: 2,
    );

    final game = GameModel(
      id: gameId,
      name: name,
      board: board,
      status: GameStatus.playing,
      actions: const [],
      createdAt: DateTime.now(),
    );

    _games[gameId] = game;
    return game;
  }

  @override
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final game = _games[gameId];
    if (game == null) {
      throw Exception('Game not found');
    }

    // Simple simulation: just update the robot position for move action
    if (action == ActionType.move) {
      final robot = game.board.robot;
      Position newPosition = robot.position;

      switch (direction) {
        case Direction.north:
          newPosition = Position(x: robot.position.x, y: robot.position.y - 1);
          break;
        case Direction.south:
          newPosition = Position(x: robot.position.x, y: robot.position.y + 1);
          break;
        case Direction.east:
          newPosition = Position(x: robot.position.x + 1, y: robot.position.y);
          break;
        case Direction.west:
          newPosition = Position(x: robot.position.x - 1, y: robot.position.y);
          break;
      }

      // Update robot position
      final updatedRobot = robot.copyWith(position: newPosition);

      // Update cells
      final updatedCells = game.board.cells.map((cell) {
        if (cell.position == robot.position) {
          return cell.copyWith(type: CellType.empty);
        } else if (cell.position == newPosition &&
            cell.type == CellType.empty) {
          return cell.copyWith(type: CellType.robot);
        }
        return cell;
      }).toList();

      final updatedBoard = GameBoard(
        width: game.board.width,
        height: game.board.height,
        cells: updatedCells,
        robot: updatedRobot,
        princess: game.board.princess,
        flowersRemaining: game.board.flowersRemaining,
        totalObstacles: game.board.totalObstacles,
        obstaclesRemaining: game.board.obstaclesRemaining,
      );

      final updatedGame = GameModel(
        id: game.id,
        name: game.name,
        board: updatedBoard,
        status: game.status,
        createdAt: game.createdAt,
        actions: game.actions,
        updatedAt: game.updatedAt,
      );
      _games[gameId] = updatedGame;
      return updatedGame;
    }

    return game;
  }

  @override
  Future<GameModel> getGame(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final game = _games[gameId];
    if (game == null) {
      throw Exception('Game not found');
    }

    return game;
  }

  @override
  Future<List<GameModel>> getGames({int limit = 10, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    var games = _games.values.toList();

    if (status != null) {
      GameStatus? filterStatus;
      switch (status) {
        case 'in_progress':
          filterStatus = GameStatus.playing;
          break;
        case 'victory':
          filterStatus = GameStatus.won;
          break;
        case 'game_over':
          filterStatus = GameStatus.gameOver;
          break;
      }

      if (filterStatus != null) {
        games = games.where((g) => g.status == filterStatus).toList();
      }
    }

    games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return games.take(limit).toList();
  }

  @override
  Future<Map<String, dynamic>> getGameHistory(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final game = _games[gameId];
    if (game == null) {
      throw Exception('Game not found');
    }

    return {
      'id': gameId,
      'history': [game.board.toJson()],
    };
  }

  @override
  Future<GameModel> autoPlay(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final game = _games[gameId];
    if (game == null) {
      throw Exception('Game not found');
    }

    // Simulate auto-play: move robot to princess, collect/deliver flowers, mark as won
    final princess = game.board.princess;
    final flowersToDeliver = game.board.flowersRemaining;

    final updatedRobot = game.board.robot.copyWith(
      position: princess.position,
      deliveredFlowers: List.generate(
        flowersToDeliver,
        (i) => Position(x: i, y: i),
      ),
    );

    final updatedPrincess = princess.copyWith(
      flowersReceived: flowersToDeliver,
    );

    final updatedBoard = game.board.copyWith(
      robot: updatedRobot,
      princess: updatedPrincess,
      flowersRemaining: 0,
      obstaclesRemaining: 0,
    );

    final updatedGame = GameModel(
      id: game.id,
      name: game.name,
      board: updatedBoard,
      status: GameStatus.won,
      actions: game.actions,
      createdAt: game.createdAt,
      updatedAt: DateTime.now(),
    );

    _games[gameId] = updatedGame;
    return updatedGame;
  }

  /// Helper method to clear all games (useful for test setup/teardown)
  void clearGames() {
    _games.clear();
    _gameCounter = 0;
  }

  /// Helper method to get the number of games
  int get gameCount => _games.length;
}
