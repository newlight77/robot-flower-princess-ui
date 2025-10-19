import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('should log messages without throwing', () {
      expect(() => Logger.log('Test message'), returnsNormally);
      expect(() => Logger.info('Info message'), returnsNormally);
      expect(() => Logger.error('Error message'), returnsNormally);
      expect(() => Logger.warning('Warning message'), returnsNormally);
      expect(() => Logger.debug('Debug message'), returnsNormally);
    });
  });
}
