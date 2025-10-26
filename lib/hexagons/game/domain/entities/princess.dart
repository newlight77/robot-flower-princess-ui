import 'package:equatable/equatable.dart';
import '../value_objects/position.dart';

enum PrincessMood {
  happy,
  sad,
  angry,
  neutral;

  String get emoji {
    switch (this) {
      case PrincessMood.happy:
        return '😊';
      case PrincessMood.sad:
        return '😢';
      case PrincessMood.angry:
        return '😠';
      case PrincessMood.neutral:
        return '😐';
    }
  }
}

class Princess extends Equatable {
  final Position position;
  final List<Position> flowersReceivedList;
  final PrincessMood mood;

  const Princess({
    required this.position,
    this.flowersReceivedList = const [],
    this.mood = PrincessMood.neutral,
  });

  // Backward compatibility getter
  int get flowersReceived => flowersReceivedList.length;

  Princess copyWith({
    Position? position,
    List<Position>? flowersReceivedList,
    PrincessMood? mood,
  }) {
    return Princess(
      position: position ?? this.position,
      flowersReceivedList: flowersReceivedList ?? this.flowersReceivedList,
      mood: mood ?? this.mood,
    );
  }

  @override
  List<Object> get props => [position, flowersReceivedList, mood];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'flowers_received': flowersReceivedList.map((p) => p.toJson()).toList(),
      'mood': mood.name,
    };
  }

  factory Princess.fromJson(Map<String, dynamic> json) {
    try {
      final position =
          Position.fromJson(json['position'] as Map<String, dynamic>);

      // Handle both list and integer formats for backward compatibility
      List<Position> flowersReceivedList = [];
      final flowersReceivedData = json['flowers_received'];

      if (flowersReceivedData != null) {
        if (flowersReceivedData is List) {
          // New format: list of positions
          for (var item in flowersReceivedData) {
            if (item is Map<String, dynamic>) {
              // If item has 'row' and 'col', it's a position directly
              if (item.containsKey('row') && item.containsKey('col')) {
                flowersReceivedList.add(Position.fromJson(item));
              }
              // If item has 'position' nested, extract it
              else if (item.containsKey('position')) {
                flowersReceivedList.add(Position.fromJson(
                    item['position'] as Map<String, dynamic>));
              }
            }
          }
        } else if (flowersReceivedData is int) {
          // Old format: integer count - create dummy positions
          for (int i = 0; i < flowersReceivedData; i++) {
            flowersReceivedList.add(const Position(x: -1, y: -1));
          }
        }
      }

      PrincessMood mood;
      final moodString = json['mood'] as String? ?? 'neutral';
      switch (moodString) {
        case 'happy':
          mood = PrincessMood.happy;
          break;
        case 'sad':
          mood = PrincessMood.sad;
          break;
        case 'angry':
          mood = PrincessMood.angry;
          break;
        case 'neutral':
        default:
          mood = PrincessMood.neutral;
          break;
      }

      return Princess(
        position: position,
        flowersReceivedList: flowersReceivedList,
        mood: mood,
      );
    } catch (e) {
      throw Exception('Failed to parse Princess from JSON: $e. JSON: $json');
    }
  }
}
