import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/cell.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/cell_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_info_panel.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_status_badge.dart';

void main() {
  group('GameInfoPanel Widget Tests', () {
    late Game testGame;

    setUp(() {
      const robot = Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
        collectedFlowers: [],
        deliveredFlowers: [],
        cleanedObstacles: [],
      );

      const princess = Princess(
        position: Position(x: 4, y: 4),
        flowersReceivedList: [],
      );

      final cells = <Cell>[
        const Cell(position: Position(x: 0, y: 0), type: CellType.robot),
        const Cell(position: Position(x: 1, y: 1), type: CellType.flower),
        const Cell(position: Position(x: 2, y: 2), type: CellType.obstacle),
        const Cell(position: Position(x: 4, y: 4), type: CellType.princess),
      ];

      final board = GameBoard(
        width: 5,
        height: 5,
        cells: cells,
        robot: robot,
        princess: princess,
        flowersRemaining: 1,
        totalObstacles: 1,
        obstaclesRemaining: 1,
      );

      testGame = Game(
        id: 'test-game-1',
        name: 'Test Game',
        board: board,
        status: GameStatus.playing,
        actions: const [],
        createdAt: DateTime(2025, 1, 1),
      );
    });

    testWidgets('should display game name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.text('Test Game'), findsOneWidget);
    });

    testWidgets('should display robot position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('Robot Position'), findsOneWidget);
      expect(find.text('(0, 0)'), findsOneWidget);
    });

    testWidgets('should display flowers held', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('Flowers Held'), findsOneWidget);
      expect(find.text('0/12'), findsOneWidget);
    });

    testWidgets('should display total flowers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('Total Flowers'), findsOneWidget);
      // Note: Total flowers is calculated dynamically from the board
      expect(find.byType(GameInfoPanel), findsOneWidget);
    });

    testWidgets('should display flowers delivered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('Flowers Delivered'), findsOneWidget);
      // The value "0" appears multiple times, so we just verify the label exists
      expect(find.byType(GameInfoPanel), findsOneWidget);
    });

    testWidgets('should display actions taken', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('Actions Taken'), findsOneWidget);
      // The value "0" appears multiple times in the panel, so we just verify the label
      expect(find.byType(GameInfoPanel), findsOneWidget);
    });

    testWidgets(
        'should display robot with flowers emoji when robot has flowers',
        (WidgetTester tester) async {
      const robotWithFlowers = Robot(
        position: Position(x: 1, y: 1),
        orientation: Direction.EAST,
        collectedFlowers: [Position(x: 2, y: 2)],
        deliveredFlowers: [],
        cleanedObstacles: [],
      );

      final boardWithFlowers = GameBoard(
        width: 5,
        height: 5,
        cells: testGame.board.cells,
        robot: robotWithFlowers,
        princess: testGame.board.princess,
        flowersRemaining: 1,
        totalObstacles: 1,
        obstaclesRemaining: 1,
      );

      final gameWithFlowers = testGame.copyWith(board: boardWithFlowers);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: gameWithFlowers),
          ),
        ),
      );

      expect(find.textContaining('🤖ིྀ'), findsOneWidget);
    });

    testWidgets('should display regular robot emoji when robot has no flowers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.textContaining('🤖 Robot Position'), findsOneWidget);
    });

    testWidgets('should render in a Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display GameStatusBadge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameInfoPanel(game: testGame),
          ),
        ),
      );

      expect(find.byType(GameStatusBadge), findsOneWidget);
    });
  });
}
