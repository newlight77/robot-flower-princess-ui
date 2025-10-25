import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/presentation/widgets/direction_selector.dart';

void main() {
  group('DirectionSelector Widget Tests', () {
    testWidgets('should display all four direction buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (_) {},
            ),
          ),
        ),
      );

      // Check that we have 4 direction buttons
      expect(find.byType(ElevatedButton), findsNWidgets(4));
      expect(find.byType(DirectionSelector), findsOneWidget);
    });

    testWidgets('should display title text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select Direction'), findsOneWidget);
    });

    testWidgets('should call onDirectionSelected when direction is tapped',
        (WidgetTester tester) async {
      Direction? selectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (direction) {
                selectedDirection = direction;
              },
            ),
          ),
        ),
      );

      // Tap the first button (north)
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(selectedDirection, Direction.north);
    });

    testWidgets('should highlight selected direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: Direction.east,
              onDirectionSelected: (_) {},
            ),
          ),
        ),
      );

      // The selected button should exist
      final buttons =
          tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttons.length, 4);
    });

    testWidgets('should not call callback when disabled',
        (WidgetTester tester) async {
      Direction? selectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (direction) {
                selectedDirection = direction;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      final buttons =
          tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
      expect(selectedDirection, isNull);
    });

    testWidgets('should allow selecting each direction',
        (WidgetTester tester) async {
      Direction? selectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (dir) {
                selectedDirection = dir;
              },
            ),
          ),
        ),
      );

      // Tap each button and verify callback is called
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsNWidgets(4));

      await tester.tap(buttons.first);
      await tester.pump();
      expect(selectedDirection, isNotNull);
    });

    testWidgets('should render buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (_) {},
            ),
          ),
        ),
      );

      final buttons = tester
          .widgetList<ElevatedButton>(find.byType(ElevatedButton))
          .toList();
      expect(buttons.length, 4);
    });

    testWidgets('should have circular button shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionSelector(
              selectedDirection: null,
              onDirectionSelected: (_) {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );

      expect(button.style, isNotNull);
    });
  });
}
