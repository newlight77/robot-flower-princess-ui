import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
        'collected':
            collectedFlowers.map((p) => {'position': p.toJson()}).toList(),
        'delivered':
            deliveredFlowers.map((p) => {'position': p.toJson()}).toList(),
        'collection_capacity': collectionCapacity,
      },
      'obstacles': {
        'cleaned':
            cleanedObstacles.map((p) => {'position': p.toJson()}).toList(),
      },
      'executed_actions': executedActions.map((a) => a.toJson()).toList(),
    };
  }

  factory Robot.fromJson(Map<String, dynamic> json) {
    try {
      // Debug logging
      debugPrint('DEBUG: Robot.fromJson - Full JSON: $json');

      Position position;
      if (json['position'] != null) {
        position = Position.fromJson(json['position'] as Map<String, dynamic>);
      } else {
        throw Exception('Robot position is required but was null');
      }

      Direction orientation;
      if (json['orientation'] != null) {
        orientation =
            Direction.values.firstWhere((e) => e.name == json['orientation']);
      } else {
        orientation = Direction.north;
      }

      // Parse flowers data
      List<Position> collectedFlowers = [];
      List<Position> deliveredFlowers = [];
      int collectionCapacity = 12;

      if (json['flowers'] != null) {
        final flowersData = json['flowers'] as Map<String, dynamic>;
        debugPrint('DEBUG: Robot flowers data: $flowersData');

        if (flowersData['collected'] != null) {
          final collected = flowersData['collected'];
          debugPrint(
              'DEBUG: Robot collected flowers: $collected (type: ${collected.runtimeType})');

          try {
            // Handle both list and integer formats
            if (collected is List) {
              for (var item in collected) {
                debugPrint(
                    'DEBUG: Processing collected item: $item (type: ${item.runtimeType})');
                if (item is Map<String, dynamic>) {
                  if (item.containsKey('position')) {
                    final pos = Position.fromJson(
                        item['position'] as Map<String, dynamic>);
                    collectedFlowers.add(pos);
                    debugPrint('DEBUG: Added collected position: $pos');
                  }
                }
              }
            } else if (collected is int) {
              // If backend sends just a count, create dummy positions to represent count
              debugPrint('DEBUG: Backend sent collected count: $collected');
              for (int i = 0; i < collected; i++) {
                collectedFlowers
                    .add(const Position(x: -1, y: -1)); // Dummy position
              }
            }
          } catch (e, stackTrace) {
            debugPrint('ERROR parsing collected flowers: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        }

        if (flowersData['delivered'] != null) {
          final delivered = flowersData['delivered'];
          debugPrint(
              'DEBUG: Robot delivered flowers: $delivered (type: ${delivered.runtimeType})');

          try {
            // Handle both list and integer formats
            if (delivered is List) {
              for (var item in delivered) {
                debugPrint(
                    'DEBUG: Processing delivered item: $item (type: ${item.runtimeType})');
                if (item is Map<String, dynamic>) {
                  if (item.containsKey('position')) {
                    final pos = Position.fromJson(
                        item['position'] as Map<String, dynamic>);
                    deliveredFlowers.add(pos);
                    debugPrint('DEBUG: Added delivered position: $pos');
                  }
                }
              }
            } else if (delivered is int) {
              // If backend sends just a count, create dummy positions
              debugPrint('DEBUG: Backend sent delivered count: $delivered');
              for (int i = 0; i < delivered; i++) {
                deliveredFlowers
                    .add(const Position(x: -1, y: -1)); // Dummy position
              }
            }
          } catch (e, stackTrace) {
            debugPrint('ERROR parsing delivered flowers: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        }

        collectionCapacity = flowersData['collection_capacity'] as int? ?? 12;
      }

      debugPrint(
          'DEBUG: Robot hasFlowers check: collectedFlowers=${collectedFlowers.length}, deliveredFlowers=${deliveredFlowers.length}, hasFlowers=${collectedFlowers.length - deliveredFlowers.length > 0}');

      // Parse obstacles data
      List<Position> cleanedObstacles = [];
      if (json['obstacles'] != null) {
        final obstaclesData = json['obstacles'] as Map<String, dynamic>;
        if (obstaclesData['cleaned'] != null) {
          final cleaned = obstaclesData['cleaned'] as List<dynamic>;
          cleanedObstacles = cleaned
              .map((item) => Position.fromJson((item
                  as Map<String, dynamic>)['position'] as Map<String, dynamic>))
              .toList();
        }
      }

      // Parse executed actions
      List<GameAction> executedActions = [];
      if (json['executed_actions'] != null) {
        final actions = json['executed_actions'] as List<dynamic>;
        executedActions = actions
            .map(
                (action) => GameAction.fromJson(action as Map<String, dynamic>))
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
