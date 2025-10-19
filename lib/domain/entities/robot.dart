import 'package:equatable/equatable.dart';
import '../value_objects/position.dart';
import '../value_objects/direction.dart';

class Robot extends Equatable {
  final Position position;
  final Direction orientation;
  final int flowersHeld;

  const Robot({
    required this.position,
    required this.orientation,
    this.flowersHeld = 0,
  });

  Robot copyWith({
    Position? position,
    Direction? orientation,
    int? flowersHeld,
  }) {
    return Robot(
      position: position ?? this.position,
      orientation: orientation ?? this.orientation,
      flowersHeld: flowersHeld ?? this.flowersHeld,
    );
  }

  bool get hasFlowers => flowersHeld > 0;
  bool get canPickMore => flowersHeld < 12;

  @override
  List<Object> get props => [position, orientation, flowersHeld];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'orientation': orientation.name,
      'flowersHeld': flowersHeld,
    };
  }

  factory Robot.fromJson(Map<String, dynamic> json) {
    try {
      return Robot(
        position: json['position'] != null
            ? Position.fromJson(json['position'] as Map<String, dynamic>)
            : throw Exception('Robot position is required but was null'),
        orientation: json['orientation'] != null
            ? Direction.values.firstWhere((e) => e.name == json['orientation'])
            : Direction.north,
        flowersHeld: json['flowersHeld'] as int? ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to parse Robot from JSON: $e. JSON: $json');
    }
  }
}
