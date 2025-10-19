import 'package:equatable/equatable.dart';
import 'game_board.dart';
import 'game_action.dart';
import '../value_objects/game_status.dart';

class Game extends Equatable {
  final String id;
  final String name;
  final GameBoard board;
  final GameStatus status;
  final List<GameAction> actions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Game({
    required this.id,
    required this.name,
    required this.board,
    required this.status,
    this.actions = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Game copyWith({
    String? id,
    String? name,
    GameBoard? board,
    GameStatus? status,
    List<GameAction>? actions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      board: board ?? this.board,
      status: status ?? this.status,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        board,
        status,
        actions,
        createdAt,
        updatedAt,
      ];

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

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      board: GameBoard.fromJson(json['board'] as Map<String, dynamic>),
      status: GameStatus.values.firstWhere((e) => e.name == json['status']),
      actions: (json['actions'] as List?)
              ?.map((a) => GameAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
