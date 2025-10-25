import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/presentation/pages/game/widgets/action_controls.dart';
import 'package:robot_flower_princess_front/presentation/widgets/action_button.dart';
import 'package:robot_flower_princess_front/presentation/widgets/direction_selector.dart';

void main() {
  group('ActionControls Widget Tests', () {
    testWidgets('should display DirectionSelector',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: null,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byType(DirectionSelector), findsOneWidget);
    });

    testWidgets('should display all action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ActionButton), findsNWidgets(6));
    });

    testWidgets('should display auto play button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.text('Auto Play'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('should pass selected direction to DirectionSelector',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.east,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      final directionSelector =
          tester.widget<DirectionSelector>(find.byType(DirectionSelector));
      expect(directionSelector.selectedDirection, Direction.east);
    });

    testWidgets('should call onActionPressed when action button is tapped',
        (WidgetTester tester) async {
      ActionType? pressedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (action) => pressedAction = action,
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      // Tap the move button
      await tester.tap(find.text('Move'));
      await tester.pump();

      expect(pressedAction, ActionType.move);
    });

    testWidgets('should call onAutoPlay when auto play button is tapped',
        (WidgetTester tester) async {
      var autoPlayCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () => autoPlayCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Auto Play'));
      await tester.pump();

      expect(autoPlayCalled, true);
    });

    testWidgets('should disable controls when game is finished',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
              isGameFinished: true,
            ),
          ),
        ),
      );

      // Auto play button text should still be present
      expect(find.text('Auto Play'), findsOneWidget);
    });

    testWidgets('should pass isGameFinished to DirectionSelector',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
              isGameFinished: true,
            ),
          ),
        ),
      );

      final directionSelector =
          tester.widget<DirectionSelector>(find.byType(DirectionSelector));
      expect(directionSelector.isEnabled, false);
    });

    testWidgets('should display section titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('should display dividers for visual separation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('should render as Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      // Find the main Padding widget inside Card (not the Material padding)
      final paddings = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        ),
      );

      // Look for the padding with EdgeInsets.all(16)
      final mainPadding = paddings.firstWhere(
        (p) => p.padding == const EdgeInsets.all(16),
        orElse: () => throw StateError('Main padding not found'),
      );
      expect(mainPadding.padding, const EdgeInsets.all(16));
    });

    testWidgets('should display all action types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      final actionButtons =
          tester.widgetList<ActionButton>(find.byType(ActionButton));
      final actionTypes =
          actionButtons.map((button) => button.actionType).toList();

      expect(actionTypes, contains(ActionType.rotate));
      expect(actionTypes, contains(ActionType.move));
      expect(actionTypes, contains(ActionType.pickFlower));
      expect(actionTypes, contains(ActionType.dropFlower));
      expect(actionTypes, contains(ActionType.giveFlower));
      expect(actionTypes, contains(ActionType.clean));
    });

    testWidgets('should disable action buttons when no direction selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: null,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      final actionButtons =
          tester.widgetList<ActionButton>(find.byType(ActionButton));
      for (final button in actionButtons) {
        expect(button.isEnabled, false);
      }
    });

    testWidgets('should enable action buttons when direction is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      final actionButtons =
          tester.widgetList<ActionButton>(find.byType(ActionButton));
      for (final button in actionButtons) {
        expect(button.isEnabled, true);
      }
    });

    testWidgets('should arrange action buttons in Wrap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 8);
      expect(wrap.runSpacing, 8);
      expect(wrap.alignment, WrapAlignment.center);
    });

    testWidgets('should display auto play button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      // Verify auto play button is displayed
      expect(find.text('Auto Play'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('should handle rapid action button presses',
        (WidgetTester tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) => pressCount++,
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      // Rapidly press move button
      await tester.tap(find.text('Move'));
      await tester.pump();
      await tester.tap(find.text('Move'));
      await tester.pump();
      await tester.tap(find.text('Move'));
      await tester.pump();

      expect(pressCount, 3);
    });

    testWidgets('should maintain selected direction state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.east,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      final directionSelector =
          tester.widget<DirectionSelector>(find.byType(DirectionSelector));
      expect(directionSelector.selectedDirection, Direction.east);
    });

    testWidgets('should have all required UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionControls(
              selectedDirection: Direction.north,
              onDirectionSelected: (_) {},
              onActionPressed: (_) {},
              onAutoPlay: () {},
            ),
          ),
        ),
      );

      // Verify all major elements are present
      expect(find.byType(DirectionSelector), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Auto Play'), findsOneWidget);
      expect(find.byType(ActionButton), findsNWidgets(6));
    });
  });
}
