import 'package:equatable/equatable.dart';
import '../value_objects/action_type.dart';
import '../value_objects/direction.dart';

class GameAction extends Equatable {
  final ActionType type;
  final Direction direction;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;

  const GameAction({
    required this.type,
    required this.direction,
    required this.timestamp,
    this.success = true,
    this.errorMessage,
  });

  GameAction copyWith({
    ActionType? type,
    Direction? direction,
    DateTime? timestamp,
    bool? success,
    String? errorMessage,
  }) {
    return GameAction(
      type: type ?? this.type,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [type, direction, timestamp, success, errorMessage];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'direction': direction.name,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  factory GameAction.fromJson(Map<String, dynamic> json) {
    return GameAction(
      type: ActionType.values.firstWhere((e) => e.name == json['type']),
      direction:
          Direction.values.firstWhere((e) => e.name == json['direction']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
