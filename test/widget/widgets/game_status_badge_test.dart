import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_status_badge.dart';

void main() {
  group('GameStatusBadge Widget Tests', () {
    testWidgets('should render badge widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusBadge(status: GameStatus.playing),
          ),
        ),
      );

      expect(find.byType(GameStatusBadge), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render for all game statuses',
        (WidgetTester tester) async {
      for (final status in GameStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameStatusBadge(status: status),
            ),
          ),
        );

        expect(find.byType(GameStatusBadge), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should have padding and decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusBadge(status: GameStatus.playing),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GameStatusBadge),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.padding, isNotNull);
      expect(container.decoration, isNotNull);
    });
  });
}
