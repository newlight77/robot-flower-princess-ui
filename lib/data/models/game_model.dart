import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_action.dart';
import '../../domain/value_objects/game_status.dart';
import '../../core/utils/logger.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.board,
    required super.status,
    required super.createdAt,
    super.actions,
    super.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.debug('GameModel.fromJson - Parsing JSON: $json', tag: 'GameModel');

      // Parse each field individually with detailed logging
      final rawId = (json['id'] ?? json['_id'] ?? json['gameId']) as String?;
      if (rawId == null || rawId.isEmpty) {
        throw Exception('Game id is missing or empty');
      }
      final id = rawId;
      Logger.debug('GameModel.fromJson - id: $id', tag: 'GameModel');

      final name = json['name'] as String? ?? 'Unnamed Game';
      Logger.debug('GameModel.fromJson - name: $name', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - board field: ${json['board']}', tag: 'GameModel');
      final board = json['board'] != null
          ? GameBoard.fromJson(json['board'] as Map<String, dynamic>)
          : throw Exception('Board is required but was null');
      Logger.debug('GameModel.fromJson - board parsed successfully', tag: 'GameModel');

      // Handle backend status format
      String statusString = json['status'] as String? ?? 'playing';
      GameStatus status;

      switch (statusString) {
        case 'in_progress':
          status = GameStatus.playing;
          break;
        case 'won':
          status = GameStatus.won;
          break;
        case 'gameOver':
        case 'game_over':
          status = GameStatus.gameOver;
          break;
        default:
          status = GameStatus.playing;
          break;
      }
      Logger.debug('GameModel.fromJson - status: $status', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - actions field: ${json['actions']}', tag: 'GameModel');
      final actions = (json['actions'] as List?)
              ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [];
      Logger.debug('GameModel.fromJson - actions parsed successfully, count: ${actions.length}', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - createdAt field: ${json['createdAt']}', tag: 'GameModel');
      final createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now();
      Logger.debug('GameModel.fromJson - createdAt: $createdAt', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - updatedAt field: ${json['updatedAt']}', tag: 'GameModel');
      final updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null;
      Logger.debug('GameModel.fromJson - updatedAt: $updatedAt', tag: 'GameModel');

      final gameModel = GameModel(
        id: id,
        name: name,
        board: board,
        status: status,
        actions: actions,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      Logger.info('GameModel.fromJson - Successfully created GameModel', tag: 'GameModel');
      return gameModel;
    } catch (e, stackTrace) {
      Logger.error('GameModel.fromJson - Error: $e', tag: 'GameModel', error: e);
      Logger.error('GameModel.fromJson - Stack trace: $stackTrace', tag: 'GameModel');
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
