import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

void main() {
  group('Direction Value Object', () {
    test('should have all four directions', () {
      expect(Direction.values.length, 4);
      expect(Direction.values, contains(Direction.north));
      expect(Direction.values, contains(Direction.east));
      expect(Direction.values, contains(Direction.south));
      expect(Direction.values, contains(Direction.west));
    });

    test('should have display names', () {
      expect(Direction.north.displayName, '⬆️ North');
      expect(Direction.east.displayName, '➡️ East');
      expect(Direction.south.displayName, '⬇️ South');
      expect(Direction.west.displayName, '⬅️ West');
    });

    test('should have icons', () {
      expect(Direction.north.icon, '⬆️');
      expect(Direction.east.icon, '➡️');
      expect(Direction.south.icon, '⬇️');
      expect(Direction.west.icon, '⬅️');
    });
  });
}
