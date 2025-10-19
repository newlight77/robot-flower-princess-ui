import 'package:equatable/equatable.dart';
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
