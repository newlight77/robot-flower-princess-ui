import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_action.dart';
import '../../domain/value_objects/game_status.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.board,
    required super.status,
    required super.createdAt, super.actions,
    super.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    try {
      return GameModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        board: json['board'] != null
            ? GameBoard.fromJson(json['board'] as Map<String, dynamic>)
            : throw Exception('Board is required but was null'),
        status: json['status'] != null
            ? GameStatus.values.firstWhere((e) => e.name == json['status'])
            : GameStatus.playing,
        actions: (json['actions'] as List?)
                ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      throw Exception('Failed to parse GameModel from JSON: $e. JSON: $json');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'board': board.toJson(),
      'status': status.name,
      'actions': actions.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Game toEntity() {
    return Game(
      id: id,
      name: name,
      board: board,
      status: status,
      actions: actions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
