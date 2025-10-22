import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'robot.dart';
import 'princess.dart';
import '../value_objects/position.dart';
import '../value_objects/cell_type.dart';
import '../value_objects/direction.dart';
import '../../core/utils/logger.dart';

class GameBoard extends Equatable {
  final int width;
  final int height;
  final List<Cell> cells;
  final Robot robot;
  final Princess princess;
  final int flowersRemaining;
  final int totalObstacles;
  final int obstaclesRemaining;

  const GameBoard({
    required this.width,
    required this.height,
    required this.cells,
    required this.robot,
    required this.princess,
    required this.flowersRemaining,
    required this.totalObstacles,
    required this.obstaclesRemaining,
  });

  Cell? getCellAt(Position position) {
    try {
      return cells.firstWhere(
        (cell) =>
            cell.position.x == position.x && cell.position.y == position.y,
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

  int get totalFlowers => cells.where((c) => c.type == CellType.flower).length;
  int get flowersDelivered => totalFlowers - flowersRemaining;
  bool get isComplete => flowersRemaining == 0;

  GameBoard copyWith({
    int? width,
    int? height,
    List<Cell>? cells,
    Robot? robot,
    Princess? princess,
    int? flowersRemaining,
    int? totalObstacles,
    int? obstaclesRemaining,
  }) {
    return GameBoard(
      width: width ?? this.width,
      height: height ?? this.height,
      cells: cells ?? this.cells,
      robot: robot ?? this.robot,
      princess: princess ?? this.princess,
      flowersRemaining: flowersRemaining ?? this.flowersRemaining,
      totalObstacles: totalObstacles ?? this.totalObstacles,
      obstaclesRemaining: obstaclesRemaining ?? this.obstaclesRemaining,
    );
  }

  @override
  List<Object> get props => [
        width,
        height,
        cells,
        robot,
        princess,
        flowersRemaining,
        totalObstacles,
        obstaclesRemaining,
      ];

  Map<String, dynamic> toJson() {
    return {
      'rows': height,
      'cols': width,
      'grid': _cellsToGrid(),
      'robot': robot.toJson(),
      'princess': princess.toJson(),
      'flowers': {
        'total': cells.where((c) => c.type == CellType.flower).length,
        'remaining': flowersRemaining,
      },
      'obstacles': {
        'total': totalObstacles,
        'remaining': obstaclesRemaining,
      },
    };
  }

  factory GameBoard.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('GameBoard.fromJson - Parsing JSON: $json', tag: 'GameBoard');

      // Handle both old format (width/height) and new format (rows/cols)
      final width = json['width'] as int? ?? json['cols'] as int? ?? 0;
      final height = json['height'] as int? ?? json['rows'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - width: $width, height: $height', tag: 'GameBoard');

      List<Cell> cells = [];
      List<List<dynamic>>? grid;

      // Handle grid format from backend
      if (json['grid'] != null) {
        final gridData = json['grid'] as List<dynamic>;
        // Convert to List<List<dynamic>> safely
        grid = gridData.map((row) => row as List<dynamic>).toList();
        cells = _parseGridToCells(grid);
        Logger.debug('GameBoard.fromJson - grid parsed to ${cells.length} cells', tag: 'GameBoard');
      } else if (json['cells'] != null) {
        // Handle old cells format
        cells = (json['cells'] as List?)
                ?.map((c) => Cell.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [];
        Logger.debug('GameBoard.fromJson - cells parsed successfully, count: ${cells.length}', tag: 'GameBoard');
      }

      Logger.debug('GameBoard.fromJson - robot field: ${json['robot']}', tag: 'GameBoard');
      Robot robot;
      if (json['robot'] != null) {
        robot = Robot.fromJson(json['robot'] as Map<String, dynamic>);
        Logger.debug('GameBoard.fromJson - robot parsed successfully', tag: 'GameBoard');
      } else if (grid != null) {
        // Extract robot position from grid
        final robotPosition = _findRobotPositionInGrid(grid);
        robot = Robot(position: robotPosition, orientation: Direction.north);
        Logger.debug('GameBoard.fromJson - robot position extracted from grid: $robotPosition', tag: 'GameBoard');
      } else {
        // Fallback to default position
        robot = const Robot(position: Position(x: 0, y: 0), orientation: Direction.north);
        Logger.debug('GameBoard.fromJson - robot using default position', tag: 'GameBoard');
      }

      Logger.debug('GameBoard.fromJson - princess field: ${json['princess']}');
      Princess princess;
      if (json['princess'] != null) {
        princess = Princess.fromJson(json['princess'] as Map<String, dynamic>);
        Logger.debug('GameBoard.fromJson - princess parsed successfully', tag: 'GameBoard');
      } else if (grid != null) {
        // Extract princess position from grid
        final princessPosition = _findPrincessPositionInGrid(grid);
        princess = Princess(position: princessPosition);
        Logger.debug('GameBoard.fromJson - princess position extracted from grid: $princessPosition', tag: 'GameBoard');
      } else {
        // Fallback to default position
        princess = Princess(position: Position(x: width - 1, y: height - 1));
        Logger.debug('GameBoard.fromJson - princess using default position', tag: 'GameBoard');
      }

      // Parse flowers data
      int flowersRemaining = 0;
      if (json['flowers'] != null) {
        final flowersData = json['flowers'] as Map<String, dynamic>;
        flowersRemaining = flowersData['remaining'] as int? ?? 0;
      } else {
        // Count flowers from cells
        flowersRemaining = cells.where((c) => c.type == CellType.flower).length;
        Logger.debug('GameBoard.fromJson - flowers counted from cells: $flowersRemaining', tag: 'GameBoard');
      }
      Logger.debug('GameBoard.fromJson - flowersRemaining: $flowersRemaining', tag: 'GameBoard');

      // Parse obstacles data
      int totalObstacles = 0;
      int obstaclesRemaining = 0;
      if (json['obstacles'] != null) {
        final obstaclesData = json['obstacles'] as Map<String, dynamic>;
        totalObstacles = obstaclesData['total'] as int? ?? 0;
        obstaclesRemaining = obstaclesData['remaining'] as int? ?? 0;
      } else {
        // Count obstacles from cells
        totalObstacles = cells.where((c) => c.type == CellType.obstacle).length;
        obstaclesRemaining = totalObstacles;
        Logger.debug('GameBoard.fromJson - obstacles counted from cells: $totalObstacles', tag: 'GameBoard');
      }
      Logger.debug('GameBoard.fromJson - totalObstacles: $totalObstacles, obstaclesRemaining: $obstaclesRemaining', tag: 'GameBoard');

      final gameBoard = GameBoard(
        width: width,
        height: height,
        cells: cells,
        robot: robot,
        princess: princess,
        flowersRemaining: flowersRemaining,
        totalObstacles: totalObstacles,
        obstaclesRemaining: obstaclesRemaining,
      );

      Logger.info('GameBoard.fromJson - Successfully created GameBoard', tag: 'GameBoard');
      return gameBoard;
    } catch (e, stackTrace) {
      Logger.error('GameBoard.fromJson - Error: $e', tag: 'GameBoard', error: e);
      Logger.error('GameBoard.fromJson - Stack trace: $stackTrace', tag: 'GameBoard');
      throw Exception('Failed to parse GameBoard from JSON: $e. JSON: $json');
    }
  }

  static List<Cell> _parseGridToCells(List<List<dynamic>> grid) {
    final cells = <Cell>[];

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final cellValue = grid[row][col].toString();
        final position = Position(x: col, y: row);

        CellType cellType;
        switch (cellValue) {
          case '🤖':
            // Robot cell - handled separately
            continue;
          case '👑':
            // Princess cell - handled separately
            continue;
          case '🌸':
            cellType = CellType.flower;
            break;
          case '🗑️':
            cellType = CellType.obstacle;
            break;
          case '⬜':
          default:
            cellType = CellType.empty;
            break;
        }

        cells.add(Cell(position: position, type: cellType));
      }
    }

    return cells;
  }

  List<List<String>> _cellsToGrid() {
    final grid = List.generate(height, (row) => List.generate(width, (col) => '⬜'));

    // Place cells
    for (final cell in cells) {
      String emoji;
      switch (cell.type) {
        case CellType.flower:
          emoji = '🌸';
          break;
        case CellType.obstacle:
          emoji = '🗑️';
          break;
        default:
          emoji = '⬜';
          break;
      }
      grid[cell.position.y][cell.position.x] = emoji;
    }

    // Place robot
    grid[robot.position.y][robot.position.x] = '🤖';

    // Place princess
    grid[princess.position.y][princess.position.x] = '👑';

    return grid;
  }

  static Position _findRobotPositionInGrid(List<List<dynamic>> grid) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col].toString() == '🤖') {
          return Position(x: col, y: row);
        }
      }
    }
    // Fallback to top-left if not found
    return const Position(x: 0, y: 0);
  }

  static Position _findPrincessPositionInGrid(List<List<dynamic>> grid) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col].toString() == '👑') {
          return Position(x: col, y: row);
        }
      }
    }
    // Fallback to bottom-right if not found
    return Position(x: grid[0].length - 1, y: grid.length - 1);
  }
}
