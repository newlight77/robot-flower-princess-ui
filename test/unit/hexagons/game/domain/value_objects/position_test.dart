import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';

void main() {
  group('Position Value Object', () {
    test('should create position with coordinates', () {
      const position = Position(x: 5, y: 10);

      expect(position.x, 5);
      expect(position.y, 10);
    });

    test('should support equality', () {
      const position1 = Position(x: 3, y: 4);
      const position2 = Position(x: 3, y: 4);
      const position3 = Position(x: 3, y: 5);

      expect(position1, position2);
      expect(position1 == position3, false);
    });

    test('should create copy with modified fields', () {
      const original = Position(x: 1, y: 2);
      final copy = original.copyWith(x: 5);

      expect(copy.x, 5);
      expect(copy.y, 2);
    });

    test('should serialize to JSON', () {
      const position = Position(x: 7, y: 8);
      final json = position.toJson();

      expect(json['x'], 7);
      expect(json['y'], 8);
    });

    test('should deserialize from JSON', () {
      final json = {'x': 3, 'y': 6};
      final position = Position.fromJson(json);

      expect(position.x, 3);
      expect(position.y, 6);
    });

    test('should have meaningful toString', () {
      const position = Position(x: 2, y: 3);
      expect(position.toString(), 'Position(x: 2, y: 3)');
    });
  });
}
