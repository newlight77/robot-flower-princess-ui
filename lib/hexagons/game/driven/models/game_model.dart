import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_action.dart';
import '../../domain/value_objects/game_status.dart';
import '../../../../shared/util/logger.dart';

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
      Logger.debug('GameModel.fromJson - Parsing JSON: $json',
          tag: 'GameModel');

      // Parse each field individually with detailed logging
      final rawId = (json['id'] ?? json['_id'] ?? json['gameId']) as String?;
      final id = rawId ?? 'game_${DateTime.now().millisecondsSinceEpoch}';
      Logger.debug('GameModel.fromJson - id: $id', tag: 'GameModel');

      final name = json['name'] as String? ??
          'Game ${DateTime.now().toString().substring(0, 19)}';
      Logger.debug('GameModel.fromJson - name: $name', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - board field: ${json['board']}',
          tag: 'GameModel');

      // Handle new format where board data is at root level
      Map<String, dynamic> boardData;
      if (json['board'] != null) {
        boardData =
            Map<String, dynamic>.from(json['board'] as Map<String, dynamic>);

        // Backend puts robot/princess/flowers/obstacles at root level, not in board
        // Merge them into boardData so GameBoard.fromJson can access them
        if (json['robot'] != null) {
          boardData['robot'] = json['robot'];
        }
        if (json['princess'] != null) {
          boardData['princess'] = json['princess'];
        }
        if (json['flowers'] != null) {
          boardData['flowers'] = json['flowers'];
        }
        if (json['obstacles'] != null) {
          boardData['obstacles'] = json['obstacles'];
        }
        // Also merge rows/cols/grid if they're at root level
        if (json['rows'] != null && boardData['rows'] == null) {
          boardData['rows'] = json['rows'];
        }
        if (json['cols'] != null && boardData['cols'] == null) {
          boardData['cols'] = json['cols'];
        }
        if (json['grid'] != null && boardData['grid'] == null) {
          boardData['grid'] = json['grid'];
        }
      } else {
        // New format has board data at root level
        boardData = json;
      }

      final board = GameBoard.fromJson(boardData);
      Logger.debug('GameModel.fromJson - board parsed successfully',
          tag: 'GameModel');

      // Handle backend status format
      String statusString = json['status'] as String? ?? 'playing';
      GameStatus status;

      switch (statusString) {
        case 'in_progress':
          status = GameStatus.playing;
          break;
        case 'victory':
          status = GameStatus.won;
          break;
        case 'game_over':
          status = GameStatus.gameOver;
          break;
        default:
          status = GameStatus.playing;
          break;
      }
      Logger.debug('GameModel.fromJson - status: $status', tag: 'GameModel');

      Logger.debug('GameModel.fromJson - actions field: ${json['actions']}',
          tag: 'GameModel');
      final actions = (json['actions'] as List?)
              ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [];
      Logger.debug(
          'GameModel.fromJson - actions parsed successfully, count: ${actions.length}',
          tag: 'GameModel');

      // Handle both snake_case (from API) and camelCase (from local)
      Logger.debug(
          'GameModel.fromJson - createdAt field: ${json['createdAt']} or created_at: ${json['created_at']}',
          tag: 'GameModel');
      final createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now();
      Logger.debug('GameModel.fromJson - createdAt: $createdAt',
          tag: 'GameModel');

      Logger.debug(
          'GameModel.fromJson - updatedAt field: ${json['updatedAt']} or updated_at: ${json['updated_at']}',
          tag: 'GameModel');
      final updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null;
      Logger.debug('GameModel.fromJson - updatedAt: $updatedAt',
          tag: 'GameModel');

      final gameModel = GameModel(
        id: id,
        name: name,
        board: board,
        status: status,
        actions: actions,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      Logger.info('GameModel.fromJson - Successfully created GameModel',
          tag: 'GameModel');
      return gameModel;
    } catch (e, stackTrace) {
      Logger.error('GameModel.fromJson - Error: $e',
          tag: 'GameModel', error: e);
      Logger.error('GameModel.fromJson - Stack trace: $stackTrace',
          tag: 'GameModel');
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
