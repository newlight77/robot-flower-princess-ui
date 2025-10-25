import 'package:equatable/equatable.dart';

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
    try {
      // Handle both x/y format and col/row format from backend
      final x = json['x'] as int? ?? json['col'] as int? ?? 0;
      final y = json['y'] as int? ?? json['row'] as int? ?? 0;

      return Position(x: x, y: y);
    } catch (e) {
      throw Exception('Failed to parse Position from JSON: $e. JSON: $json');
    }
  }
}
