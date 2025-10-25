import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/presentation/widgets/action_button.dart';

void main() {
  group('ActionButton Widget Tests', () {
    testWidgets('should display button with correct icon and text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              actionType: ActionType.move,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('🚶'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
    });

    testWidgets('should call onPressed when button is tapped and enabled',
        (WidgetTester tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              actionType: ActionType.pickFlower,
              onPressed: () => pressCount++,
              isEnabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('should not call onPressed when button is disabled',
        (WidgetTester tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              actionType: ActionType.clean,
              onPressed: () => pressCount++,
              isEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(pressCount, 0);
    });

    testWidgets('should show tooltip with action display name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              actionType: ActionType.giveFlower,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, '🫴 Give Flower');
    });

    testWidgets('should render all action types correctly',
        (WidgetTester tester) async {
      for (final actionType in ActionType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActionButton(
                actionType: actionType,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text(actionType.icon), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should have correct styling when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              actionType: ActionType.rotate,
              onPressed: () {},
              isEnabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should display correct text for each action type',
        (WidgetTester tester) async {
      final testCases = {
        ActionType.rotate: 'Rotate',
        ActionType.move: 'Move',
        ActionType.pickFlower: 'Flower',
        ActionType.dropFlower: 'Flower',
        ActionType.giveFlower: 'Flower',
        ActionType.clean: 'Clean',
      };

      for (final entry in testCases.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActionButton(
                actionType: entry.key,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text(entry.value), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });
  });
}
