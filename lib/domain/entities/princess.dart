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
  final int flowersReceived;
  final PrincessMood mood;

  const Princess({
    required this.position,
    this.flowersReceived = 0,
    this.mood = PrincessMood.neutral,
  });

  Princess copyWith({
    Position? position,
    int? flowersReceived,
    PrincessMood? mood,
  }) {
    return Princess(
      position: position ?? this.position,
      flowersReceived: flowersReceived ?? this.flowersReceived,
      mood: mood ?? this.mood,
    );
  }

  @override
  List<Object> get props => [position, flowersReceived, mood];

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'flowers_received': flowersReceived,
      'mood': mood.name,
    };
  }

  factory Princess.fromJson(Map<String, dynamic> json) {
    try {
      final position = Position.fromJson(json['position'] as Map<String, dynamic>);
      final flowersReceived = json['flowers_received'] as int? ?? 0;

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
        flowersReceived: flowersReceived,
        mood: mood,
      );
    } catch (e) {
      throw Exception('Failed to parse Princess from JSON: $e. JSON: $json');
    }
  }
}
