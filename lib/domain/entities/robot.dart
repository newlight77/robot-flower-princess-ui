import 'package:equatable/equatable.dart';
import '../value_objects/position.dart';
import '../value_objects/direction.dart';
import 'game_action.dart';

class Robot extends Equatable {
  final Position position;
  final Direction orientation;
  final List<Position> collectedFlowers;
  final List<Position> deliveredFlowers;
  final List<Position> cleanedObstacles;
  final List<GameAction> executedActions;
  final int collectionCapacity;

  const Robot({
    required this.position,
    required this.orientation,
    this.collectedFlowers = const [],
    this.deliveredFlowers = const [],
    this.cleanedObstacles = const [],
    this.executedActions = const [],
    this.collectionCapacity = 12,
  });

  Robot copyWith({
    Position? position,
    Direction? orientation,
    List<Position>? collectedFlowers,
    List<Position>? deliveredFlowers,
    List<Position>? cleanedObstacles,
    List<GameAction>? executedActions,
    int? collectionCapacity,
  }) {
    return Robot(
      position: position ?? this.position,
      orientation: orientation ?? this.orientation,
      collectedFlowers: collectedFlowers ?? this.collectedFlowers,
      deliveredFlowers: deliveredFlowers ?? this.deliveredFlowers,
      cleanedObstacles: cleanedObstacles ?? this.cleanedObstacles,
      executedActions: executedActions ?? this.executedActions,
      collectionCapacity: collectionCapacity ?? this.collectionCapacity,
    );
  }

  int get flowersHeld => collectedFlowers.length - deliveredFlowers.length;
  bool get hasFlowers => flowersHeld > 0;
  bool get canPickMore => flowersHeld < collectionCapacity;

  @override
  List<Object> get props => [
        position,
        orientation,
        collectedFlowers,
        deliveredFlowers,
        cleanedObstacles,
        executedActions,
        collectionCapacity,
      ];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'orientation': orientation.name,
      'flowers': {
        'collected': collectedFlowers.map((p) => {'position': p.toJson()}).toList(),
        'delivered': deliveredFlowers.map((p) => {'position': p.toJson()}).toList(),
        'collection_capacity': collectionCapacity,
      },
      'obstacles': {
        'cleaned': cleanedObstacles.map((p) => {'position': p.toJson()}).toList(),
      },
      'executed_actions': executedActions.map((a) => a.toJson()).toList(),
    };
  }

  factory Robot.fromJson(Map<String, dynamic> json) {
    try {
      Position position;
      if (json['position'] != null) {
        position = Position.fromJson(json['position'] as Map<String, dynamic>);
      } else {
        throw Exception('Robot position is required but was null');
      }

      Direction orientation;
      if (json['orientation'] != null) {
        orientation = Direction.values.firstWhere((e) => e.name == json['orientation']);
      } else {
        orientation = Direction.north;
      }

      // Parse flowers data
      List<Position> collectedFlowers = [];
      List<Position> deliveredFlowers = [];
      int collectionCapacity = 12;

      if (json['flowers'] != null) {
        final flowersData = json['flowers'] as Map<String, dynamic>;

        if (flowersData['collected'] != null) {
          final collected = flowersData['collected'] as List<dynamic>;
          collectedFlowers = collected
              .map((item) => Position.fromJson((item as Map<String, dynamic>)['position'] as Map<String, dynamic>))
              .toList();
        }

        if (flowersData['delivered'] != null) {
          final delivered = flowersData['delivered'] as List<dynamic>;
          deliveredFlowers = delivered
              .map((item) => Position.fromJson((item as Map<String, dynamic>)['position'] as Map<String, dynamic>))
              .toList();
        }

        collectionCapacity = flowersData['collection_capacity'] as int? ?? 12;
      }

      // Parse obstacles data
      List<Position> cleanedObstacles = [];
      if (json['obstacles'] != null) {
        final obstaclesData = json['obstacles'] as Map<String, dynamic>;
        if (obstaclesData['cleaned'] != null) {
          final cleaned = obstaclesData['cleaned'] as List<dynamic>;
          cleanedObstacles = cleaned
              .map((item) => Position.fromJson((item as Map<String, dynamic>)['position'] as Map<String, dynamic>))
              .toList();
        }
      }

      // Parse executed actions
      List<GameAction> executedActions = [];
      if (json['executed_actions'] != null) {
        final actions = json['executed_actions'] as List<dynamic>;
        executedActions = actions
            .map((action) => GameAction.fromJson(action as Map<String, dynamic>))
            .toList();
      }

      return Robot(
        position: position,
        orientation: orientation,
        collectedFlowers: collectedFlowers,
        deliveredFlowers: deliveredFlowers,
        cleanedObstacles: cleanedObstacles,
        executedActions: executedActions,
        collectionCapacity: collectionCapacity,
      );
    } catch (e) {
      throw Exception('Failed to parse Robot from JSON: $e. JSON: $json');
    }
  }
}
