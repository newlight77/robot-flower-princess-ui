import 'package:equatable/equatable.dart';
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
