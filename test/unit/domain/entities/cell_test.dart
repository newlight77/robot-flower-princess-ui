import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/cell.dart';
import 'package:robot_flower_princess_front/domain/value_objects/cell_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';

void main() {
  group('Cell Entity', () {
    const testPosition = Position(x: 1, y: 2);
    const testCell = Cell(
      position: testPosition,
      type: CellType.flower,
    );

    test('should create cell with required fields', () {
      expect(testCell.position, testPosition);
      expect(testCell.type, CellType.flower);
    });

    test('should create copy with modified fields', () {
      const newPosition = Position(x: 3, y: 4);
      final copiedCell = testCell.copyWith(
        position: newPosition,
        type: CellType.obstacle,
      );

      expect(copiedCell.position, newPosition);
      expect(copiedCell.type, CellType.obstacle);
      expect(copiedCell.position, isNot(testCell.position));
    });

    test('should maintain equality for same values', () {
      const cell1 = Cell(
        position: Position(x: 1, y: 2),
        type: CellType.flower,
      );
      const cell2 = Cell(
        position: Position(x: 1, y: 2),
        type: CellType.flower,
      );

      expect(cell1, equals(cell2));
      expect(cell1.hashCode, equals(cell2.hashCode));
    });

    test('should not be equal for different values', () {
      const cell1 = Cell(
        position: Position(x: 1, y: 2),
        type: CellType.flower,
      );
      const cell2 = Cell(
        position: Position(x: 1, y: 2),
        type: CellType.obstacle,
      );

      expect(cell1, isNot(equals(cell2)));
    });

    test('should serialize to JSON', () {
      final json = testCell.toJson();

      expect(json['position'], isA<Map<String, dynamic>>());
      expect(json['position']['x'], 1);
      expect(json['position']['y'], 2);
      expect(json['type'], 'flower');
    });

    test('should deserialize from JSON', () {
      final json = {
        'position': {'x': 5, 'y': 7},
        'type': 'obstacle',
      };

      final cell = Cell.fromJson(json);

      expect(cell.position.x, 5);
      expect(cell.position.y, 7);
      expect(cell.type, CellType.obstacle);
    });

    test('should default to empty type when type is missing', () {
      final json = {
        'position': {'x': 1, 'y': 1},
      };

      final cell = Cell.fromJson(json);

      expect(cell.type, CellType.empty);
    });

    test('should throw exception when position is missing', () {
      final json = {
        'type': 'flower',
      };

      expect(
        () => Cell.fromJson(json),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle all cell types', () {
      for (final cellType in CellType.values) {
        final cell = Cell(
          position: testPosition,
          type: cellType,
        );
        final json = cell.toJson();
        final deserializedCell = Cell.fromJson(json);

        expect(deserializedCell.type, cellType);
      }
    });
  });
}
