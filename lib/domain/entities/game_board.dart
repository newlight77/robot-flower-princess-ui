import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'robot.dart';
import '../value_objects/position.dart';
import '../value_objects/cell_type.dart';

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
      print('GameBoard.fromJson - Parsing JSON: $json');

      final width = json['width'] as int? ?? 0;
      print('GameBoard.fromJson - width: $width');

      final height = json['height'] as int? ?? 0;
      print('GameBoard.fromJson - height: $height');

      print('GameBoard.fromJson - cells field: ${json['cells']}');
      final cells = (json['cells'] as List?)
              ?.map((c) => Cell.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [];
      print('GameBoard.fromJson - cells parsed successfully, count: ${cells.length}');

      print('GameBoard.fromJson - robot field: ${json['robot']}');
      final robot = json['robot'] != null
          ? Robot.fromJson(json['robot'] as Map<String, dynamic>)
          : throw Exception('Robot is required but was null');
      print('GameBoard.fromJson - robot parsed successfully');

      print('GameBoard.fromJson - princessPosition field: ${json['princessPosition']}');
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
        print('GameBoard.fromJson - princessPosition derived from cells: $princessPosition');
      }
      print('GameBoard.fromJson - princessPosition parsed successfully');

      final totalFlowers = json['totalFlowers'] as int? ?? 0;
      print('GameBoard.fromJson - totalFlowers: $totalFlowers');

      final flowersDelivered = json['flowersDelivered'] as int? ?? 0;
      print('GameBoard.fromJson - flowersDelivered: $flowersDelivered');

      final gameBoard = GameBoard(
        width: width,
        height: height,
        cells: cells,
        robot: robot,
        princessPosition: princessPosition,
        totalFlowers: totalFlowers,
        flowersDelivered: flowersDelivered,
      );

      print('GameBoard.fromJson - Successfully created GameBoard');
      return gameBoard;
    } catch (e, stackTrace) {
      print('GameBoard.fromJson - Error: $e');
      print('GameBoard.fromJson - Stack trace: $stackTrace');
      throw Exception('Failed to parse GameBoard from JSON: $e. JSON: $json');
    }
  }
}
