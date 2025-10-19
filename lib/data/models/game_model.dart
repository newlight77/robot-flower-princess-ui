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
      print('GameModel.fromJson - Parsing JSON: $json');

      // Parse each field individually with detailed logging
      final rawId = (json['id'] ?? json['_id'] ?? json['gameId']) as String?;
      if (rawId == null || rawId.isEmpty) {
        throw Exception('Game id is missing or empty');
      }
      final id = rawId;
      print('GameModel.fromJson - id: $id');

      final name = json['name'] as String? ?? '';
      print('GameModel.fromJson - name: $name');

      print('GameModel.fromJson - board field: ${json['board']}');
      final board = json['board'] != null
          ? GameBoard.fromJson(json['board'] as Map<String, dynamic>)
          : throw Exception('Board is required but was null');
      print('GameModel.fromJson - board parsed successfully');

      print('GameModel.fromJson - status field: ${json['status']}');
      final status = json['status'] != null
          ? GameStatus.values.firstWhere((e) => e.name == json['status'])
          : GameStatus.playing;
      print('GameModel.fromJson - status: $status');

      print('GameModel.fromJson - actions field: ${json['actions']}');
      final actions = (json['actions'] as List?)
              ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [];
      print('GameModel.fromJson - actions parsed successfully, count: ${actions.length}');

      print('GameModel.fromJson - createdAt field: ${json['createdAt']}');
      final createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now();
      print('GameModel.fromJson - createdAt: $createdAt');

      print('GameModel.fromJson - updatedAt field: ${json['updatedAt']}');
      final updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null;
      print('GameModel.fromJson - updatedAt: $updatedAt');

      final gameModel = GameModel(
        id: id,
        name: name,
        board: board,
        status: status,
        actions: actions,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      print('GameModel.fromJson - Successfully created GameModel');
      return gameModel;
    } catch (e, stackTrace) {
      print('GameModel.fromJson - Error: $e');
      print('GameModel.fromJson - Stack trace: $stackTrace');
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
