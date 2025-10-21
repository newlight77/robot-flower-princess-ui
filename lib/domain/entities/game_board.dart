import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'robot.dart';
import '../value_objects/position.dart';
import '../value_objects/cell_type.dart';
import '../../core/utils/logger.dart';

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
    try {
      Logger.info('GameBoard.fromJson - Parsing JSON: $json', tag: 'GameBoard');

      // Handle both old format (width/height) and new format (rows/cols)
      final width = json['width'] as int? ?? json['cols'] as int? ?? 0;
      final height = json['height'] as int? ?? json['rows'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - width: $width, height: $height', tag: 'GameBoard');

      List<Cell> cells = [];

      // Handle grid format from backend
      if (json['grid'] != null) {
        final gridData = json['grid'] as List<dynamic>;
        // Convert to List<List<dynamic>> safely
        final grid = gridData.map((row) => row as List<dynamic>).toList();
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
      final robot = json['robot'] != null
          ? Robot.fromJson(json['robot'] as Map<String, dynamic>)
          : throw Exception('Robot is required but was null');
      Logger.debug('GameBoard.fromJson - robot parsed successfully', tag: 'GameBoard');

      Logger.debug('GameBoard.fromJson - princessPosition field: ${json['princessPosition'] ?? json['princess_position']}');
      Position princessPosition;
      if (json['princessPosition'] != null) {
        princessPosition = Position.fromJson(json['princessPosition'] as Map<String, dynamic>);
      } else if (json['princess_position'] != null) {
        princessPosition = Position.fromJson(json['princess_position'] as Map<String, dynamic>);
      } else {
        // Fallback: find princess position from cells list
        final princessCell = cells.firstWhere(
          (c) => c.type.name == 'princess',
          orElse: () => const Cell(position: Position(x: 0, y: 0), type: CellType.empty),
        );
        princessPosition = princessCell.type.name == 'princess'
            ? princessCell.position
            : const Position(x: 0, y: 0);
        Logger.debug('GameBoard.fromJson - princessPosition derived from cells: $princessPosition', tag: 'GameBoard');
      }
      Logger.debug('GameBoard.fromJson - princessPosition parsed successfully', tag: 'GameBoard');

      final totalFlowers = json['totalFlowers'] as int? ?? json['total_flowers'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - totalFlowers: $totalFlowers', tag: 'GameBoard');

      final flowersDelivered = json['flowersDelivered'] as int? ?? json['flowers_delivered'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - flowersDelivered: $flowersDelivered', tag: 'GameBoard');

      final gameBoard = GameBoard(
        width: width,
        height: height,
        cells: cells,
        robot: robot,
        princessPosition: princessPosition,
        totalFlowers: totalFlowers,
        flowersDelivered: flowersDelivered,
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
}
