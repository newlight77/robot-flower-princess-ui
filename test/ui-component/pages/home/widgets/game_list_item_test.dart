import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/game.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/presentation/pages/home/widgets/game_list_item.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_status_badge.dart';

void main() {
  group('GameListItem Widget Tests', () {
    late Game testGame;

    setUp(() {
      testGame = Game(
        id: '1',
        name: 'Test Game',
        board: const GameBoard(
          width: 10,
          height: 10,
          cells: [],
          robot: Robot(
            position: Position(x: 0, y: 0),
            orientation: Direction.north,
            collectedFlowers: [],
            deliveredFlowers: [],
          ),
          princess: Princess(position: Position(x: 9, y: 9)),
          flowersRemaining: 3,
          totalObstacles: 2,
          obstaclesRemaining: 1,
        ),
        status: GameStatus.playing,
        createdAt: DateTime.now(),
      );
    });

    testWidgets('should display game name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Game'), findsOneWidget);
    });

    testWidgets('should display board size in avatar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('10x10'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display flowers delivered and actions count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should show flowers delivered out of total
      expect(find.textContaining('Flowers:'), findsOneWidget);
      expect(find.textContaining('Actions:'), findsOneWidget);
    });

    testWidgets('should display game status badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GameStatusBadge), findsOneWidget);
    });

    testWidgets('should display chevron icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('should render as Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should display correct status for won game',
        (WidgetTester tester) async {
      final wonGame = testGame.copyWith(status: GameStatus.won);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: wonGame,
              onTap: () {},
            ),
          ),
        ),
      );

      final badge = tester.widget<GameStatusBadge>(find.byType(GameStatusBadge));
      expect(badge.status, GameStatus.won);
    });

    testWidgets('should display correct status for gameOver game',
        (WidgetTester tester) async {
      final gameOverGame = testGame.copyWith(status: GameStatus.gameOver);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: gameOverGame,
              onTap: () {},
            ),
          ),
        ),
      );

      final badge = tester.widget<GameStatusBadge>(find.byType(GameStatusBadge));
      expect(badge.status, GameStatus.gameOver);
    });

    testWidgets('should handle different board sizes',
        (WidgetTester tester) async {
      final boardSizes = [5, 10, 15, 20];

      for (final size in boardSizes) {
        final game = testGame.copyWith(
          board: testGame.board.copyWith(width: size, height: size),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameListItem(
                game: game,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('${size}x$size'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle game with no actions',
        (WidgetTester tester) async {
      final game = testGame.copyWith(actions: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: game,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Actions: 0'), findsOneWidget);
    });

    testWidgets('should handle game with multiple actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Actions:'), findsOneWidget);
    });

    testWidgets('should have proper spacing and margins',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('should display trailing widgets in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.trailing, isA<Row>());
    });

    testWidgets('should handle long game names', (WidgetTester tester) async {
      final longNameGame = testGame.copyWith(
        name: 'This is a very long game name that should be displayed',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: longNameGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('This is a very long game name that should be displayed'),
        findsOneWidget,
      );
    });

    testWidgets('should display correct text styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameListItem(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      final titleText = listTile.title as Text;
      expect(titleText.style?.fontWeight, FontWeight.w600);
      expect(titleText.style?.fontSize, 16);
    });
  });
}
