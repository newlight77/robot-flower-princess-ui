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
    try {
      Logger.info('GameBoard.fromJson - Parsing JSON: $json', tag: 'GameBoard');

      final width = json['width'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - width: $width', tag: 'GameBoard');

      final height = json['height'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - height: $height', tag: 'GameBoard');

      Logger.debug('GameBoard.fromJson - cells field: ${json['cells']}', tag: 'GameBoard');
      final cells = (json['cells'] as List?)
              ?.map((c) => Cell.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [];
      Logger.debug('GameBoard.fromJson - cells parsed successfully, count: ${cells.length}', tag: 'GameBoard');

      Logger.debug('GameBoard.fromJson - robot field: ${json['robot']}', tag: 'GameBoard');
      final robot = json['robot'] != null
          ? Robot.fromJson(json['robot'] as Map<String, dynamic>)
          : throw Exception('Robot is required but was null');
      Logger.debug('GameBoard.fromJson - robot parsed successfully', tag: 'GameBoard');

      Logger.debug('GameBoard.fromJson - princessPosition field: ${json['princessPosition']}');
      Position princessPosition;
      if (json['princessPosition'] != null) {
        princessPosition = Position.fromJson(json['princessPosition'] as Map<String, dynamic>);
      } else {
        // Fallback: find princess position from cells list
        final princessCell = cells.firstWhere(
          (c) => c.type.name == 'princess',
          orElse: () => const Cell(position: Position(x: 0, y: 0), type: CellType.empty),
        );
        princessPosition = princessCell.type.name == 'princess' ? princessCell.position : const Position(x: 0, y: 0);
      Logger.debug('GameBoard.fromJson - princessPosition derived from cells: $princessPosition', tag: 'GameBoard');
      }
      Logger.debug('GameBoard.fromJson - princessPosition parsed successfully', tag: 'GameBoard');

      final totalFlowers = json['totalFlowers'] as int? ?? 0;
      Logger.debug('GameBoard.fromJson - totalFlowers: $totalFlowers', tag: 'GameBoard');

      final flowersDelivered = json['flowersDelivered'] as int? ?? 0;
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
}
