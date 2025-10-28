import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_board_widget.dart';

void main() {
  testWidgets('GameBoardWidget displays board correctly', (tester) async {
    const testBoard = GameBoard(
      width: 5,
      height: 5,
      cells: [],
      robot: Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      ),
      princess: Princess(position: Position(x: 4, y: 4)),
      flowersRemaining: 3,
      totalObstacles: 0,
      obstaclesRemaining: 0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameBoardWidget(board: testBoard),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('🤖'), findsOneWidget);
    expect(find.text('👑'), findsOneWidget);
  });
}
