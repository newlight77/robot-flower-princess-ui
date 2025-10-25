import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';

void main() {
  group('GameStatus Value Object', () {
    test('should have all status types', () {
      expect(GameStatus.values.length, 3);
      expect(GameStatus.values, contains(GameStatus.playing));
      expect(GameStatus.values, contains(GameStatus.won));
      expect(GameStatus.values, contains(GameStatus.gameOver));
    });

    test('should have display names', () {
      expect(GameStatus.playing.displayName, '🎮 Playing');
      expect(GameStatus.won.displayName, '🏆 Won');
      expect(GameStatus.gameOver.displayName, '💀 Game Over');
    });

    test('should correctly identify finished status', () {
      expect(GameStatus.playing.isFinished, false);
      expect(GameStatus.won.isFinished, true);
      expect(GameStatus.gameOver.isFinished, true);
    });
  });
}
