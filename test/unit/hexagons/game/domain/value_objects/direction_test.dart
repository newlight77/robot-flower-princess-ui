import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

void main() {
  group('Direction Value Object', () {
    test('should have all four directions', () {
      expect(Direction.values.length, 4);
      expect(Direction.values, contains(Direction.NORTH));
      expect(Direction.values, contains(Direction.EAST));
      expect(Direction.values, contains(Direction.SOUTH));
      expect(Direction.values, contains(Direction.WEST));
    });

    test('should have display names', () {
      expect(Direction.NORTH.displayName, '⬆️ North');
      expect(Direction.EAST.displayName, '➡️ East');
      expect(Direction.SOUTH.displayName, '⬇️ South');
      expect(Direction.WEST.displayName, '⬅️ West');
    });

    test('should have icons', () {
      expect(Direction.NORTH.icon, '⬆️');
      expect(Direction.EAST.icon, '➡️');
      expect(Direction.SOUTH.icon, '⬇️');
      expect(Direction.WEST.icon, '⬅️');
    });
  });
}
