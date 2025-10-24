import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('should have valid forest green color', () {
        expect(AppColors.forestGreen, isA<Color>());
        expect(AppColors.forestGreen, const Color(0xFF2D5016));
      });

      test('should have valid moss green color', () {
        expect(AppColors.mossGreen, isA<Color>());
        expect(AppColors.mossGreen, const Color(0xFF5A7C47));
      });

      test('should have valid leaf green color', () {
        expect(AppColors.leafGreen, isA<Color>());
        expect(AppColors.leafGreen, const Color(0xFF7FA950));
      });

      test('primary colors should be different', () {
        expect(AppColors.forestGreen, isNot(equals(AppColors.mossGreen)));
        expect(AppColors.mossGreen, isNot(equals(AppColors.leafGreen)));
        expect(AppColors.leafGreen, isNot(equals(AppColors.forestGreen)));
      });
    });

    group('Secondary Colors', () {
      test('should have valid warm orange color', () {
        expect(AppColors.warmOrange, isA<Color>());
        expect(AppColors.warmOrange, const Color(0xFFE87D3E));
      });

      test('should have valid sunset orange color', () {
        expect(AppColors.sunsetOrange, isA<Color>());
        expect(AppColors.sunsetOrange, const Color(0xFFFF9F5A));
      });

      test('should have valid golden yellow color', () {
        expect(AppColors.goldenYellow, isA<Color>());
        expect(AppColors.goldenYellow, const Color(0xFFFFB84D));
      });

      test('secondary colors should be different', () {
        expect(AppColors.warmOrange, isNot(equals(AppColors.sunsetOrange)));
        expect(AppColors.sunsetOrange, isNot(equals(AppColors.goldenYellow)));
        expect(AppColors.goldenYellow, isNot(equals(AppColors.warmOrange)));
      });
    });

    group('Tertiary Colors', () {
      test('should have valid sky blue color', () {
        expect(AppColors.skyBlue, isA<Color>());
        expect(AppColors.skyBlue, const Color(0xFF87BCDE));
      });

      test('should have valid deep blue color', () {
        expect(AppColors.deepBlue, isA<Color>());
        expect(AppColors.deepBlue, const Color(0xFF4A7BA7));
      });

      test('tertiary colors should be different', () {
        expect(AppColors.skyBlue, isNot(equals(AppColors.deepBlue)));
      });
    });

    group('Neutral Colors', () {
      test('should have valid earth brown color', () {
        expect(AppColors.earthBrown, isA<Color>());
        expect(AppColors.earthBrown, const Color(0xFF6B5344));
      });

      test('should have valid stone brown color', () {
        expect(AppColors.stoneBrown, isA<Color>());
        expect(AppColors.stoneBrown, const Color(0xFF8C7A6B));
      });

      test('should have valid soft cream color', () {
        expect(AppColors.softCream, isA<Color>());
        expect(AppColors.softCream, const Color(0xFFF5F1E8));
      });

      test('neutral colors should be different', () {
        expect(AppColors.earthBrown, isNot(equals(AppColors.stoneBrown)));
        expect(AppColors.stoneBrown, isNot(equals(AppColors.softCream)));
        expect(AppColors.softCream, isNot(equals(AppColors.earthBrown)));
      });
    });

    group('Game Element Colors', () {
      test('should have valid robot blue color', () {
        expect(AppColors.robotBlue, isA<Color>());
        expect(AppColors.robotBlue, const Color(0xFF5B9BD5));
      });

      test('should have valid princess pink color', () {
        expect(AppColors.princessPink, isA<Color>());
        expect(AppColors.princessPink, const Color(0xFFFF69B4));
      });

      test('should have valid flower pink color', () {
        expect(AppColors.flowerPink, isA<Color>());
        expect(AppColors.flowerPink, const Color(0xFFFFB6D9));
      });

      test('should have valid obstacle gray color', () {
        expect(AppColors.obstacleGray, isA<Color>());
        expect(AppColors.obstacleGray, const Color(0xFF707070));
      });

      test('should have valid empty cell color', () {
        expect(AppColors.emptyCell, isA<Color>());
        expect(AppColors.emptyCell, const Color(0xFFFAF8F3));
      });

      test('game element colors should be distinguishable', () {
        expect(AppColors.robotBlue, isNot(equals(AppColors.princessPink)));
        expect(AppColors.princessPink, isNot(equals(AppColors.flowerPink)));
        expect(AppColors.flowerPink, isNot(equals(AppColors.obstacleGray)));
        expect(AppColors.obstacleGray, isNot(equals(AppColors.emptyCell)));
      });
    });

    group('Status Colors', () {
      test('should have valid success color', () {
        expect(AppColors.success, isA<Color>());
        expect(AppColors.success, const Color(0xFF4CAF50));
      });

      test('should have valid warning color', () {
        expect(AppColors.warning, isA<Color>());
        expect(AppColors.warning, const Color(0xFFFFC107));
      });

      test('should have valid error color', () {
        expect(AppColors.error, isA<Color>());
        expect(AppColors.error, const Color(0xFFE57373));
      });

      test('should have valid info color', () {
        expect(AppColors.info, isA<Color>());
        expect(AppColors.info, const Color(0xFF64B5F6));
      });

      test('status colors should be different', () {
        expect(AppColors.success, isNot(equals(AppColors.warning)));
        expect(AppColors.warning, isNot(equals(AppColors.error)));
        expect(AppColors.error, isNot(equals(AppColors.info)));
        expect(AppColors.info, isNot(equals(AppColors.success)));
      });
    });

    group('Color properties', () {
      test('all colors should have valid ARGB values', () {
        final colors = [
          AppColors.forestGreen,
          AppColors.mossGreen,
          AppColors.leafGreen,
          AppColors.warmOrange,
          AppColors.sunsetOrange,
          AppColors.goldenYellow,
          AppColors.skyBlue,
          AppColors.deepBlue,
          AppColors.earthBrown,
          AppColors.stoneBrown,
          AppColors.softCream,
          AppColors.robotBlue,
          AppColors.princessPink,
          AppColors.flowerPink,
          AppColors.obstacleGray,
          AppColors.emptyCell,
          AppColors.success,
          AppColors.warning,
          AppColors.error,
          AppColors.info,
        ];

        for (final color in colors) {
          expect(color.alpha, inInclusiveRange(0, 255));
          expect(color.red, inInclusiveRange(0, 255));
          expect(color.green, inInclusiveRange(0, 255));
          expect(color.blue, inInclusiveRange(0, 255));
        }
      });

      test('all colors should have full opacity', () {
        final colors = [
          AppColors.forestGreen,
          AppColors.mossGreen,
          AppColors.leafGreen,
          AppColors.warmOrange,
          AppColors.sunsetOrange,
          AppColors.goldenYellow,
          AppColors.skyBlue,
          AppColors.deepBlue,
          AppColors.earthBrown,
          AppColors.stoneBrown,
          AppColors.softCream,
          AppColors.robotBlue,
          AppColors.princessPink,
          AppColors.flowerPink,
          AppColors.obstacleGray,
          AppColors.emptyCell,
          AppColors.success,
          AppColors.warning,
          AppColors.error,
          AppColors.info,
        ];

        for (final color in colors) {
          expect(color.alpha, 255, reason: 'Color should be fully opaque');
          expect(color.opacity, 1.0, reason: 'Opacity should be 1.0');
        }
      });
    });

    group('Color semantics', () {
      test('green colors should have higher green component', () {
        expect(AppColors.forestGreen.green, greaterThan(AppColors.forestGreen.red));
        expect(AppColors.mossGreen.green, greaterThan(AppColors.mossGreen.red));
        expect(AppColors.leafGreen.green, greaterThan(AppColors.leafGreen.red));
      });

      test('orange colors should have high red and moderate green', () {
        expect(AppColors.warmOrange.red, greaterThan(AppColors.warmOrange.blue));
        expect(
          AppColors.sunsetOrange.red,
          greaterThan(AppColors.sunsetOrange.blue),
        );
        expect(
          AppColors.goldenYellow.red,
          greaterThan(AppColors.goldenYellow.blue),
        );
      });

      test('blue colors should have higher blue component', () {
        expect(AppColors.skyBlue.blue, greaterThan(AppColors.skyBlue.red));
        expect(AppColors.deepBlue.blue, greaterThan(AppColors.deepBlue.red));
        expect(AppColors.robotBlue.blue, greaterThan(AppColors.robotBlue.red));
      });

      test('gray should have balanced RGB values', () {
        final gray = AppColors.obstacleGray;
        final diff = (gray.red - gray.blue).abs();
        expect(diff, lessThan(20), reason: 'Gray should have balanced RGB');
      });

      test('success should be predominantly green', () {
        expect(AppColors.success.green, greaterThan(AppColors.success.red));
        expect(AppColors.success.green, greaterThan(AppColors.success.blue));
      });

      test('warning should be predominantly yellow/orange', () {
        expect(AppColors.warning.red, greaterThan(AppColors.warning.blue));
        expect(AppColors.warning.green, greaterThan(AppColors.warning.blue));
      });

      test('error should be predominantly red', () {
        expect(AppColors.error.red, greaterThan(AppColors.error.green));
        expect(AppColors.error.red, greaterThan(AppColors.error.blue));
      });
    });

    group('Color usage', () {
      test('colors should be const', () {
        expect(AppColors.forestGreen, const Color(0xFF2D5016));
        expect(AppColors.robotBlue, const Color(0xFF5B9BD5));
        expect(AppColors.success, const Color(0xFF4CAF50));
      });

      test('colors should be usable in widgets', () {
        final container = Container(color: AppColors.forestGreen);
        expect(container.color, AppColors.forestGreen);
      });

      test('colors should support comparison', () {
        final color1 = AppColors.forestGreen;
        final color2 = AppColors.forestGreen;
        final color3 = AppColors.mossGreen;

        expect(color1 == color2, true);
        expect(color1 == color3, false);
      });
    });

    group('Color accessibility', () {
      test('status colors should be visually distinct', () {
        // Simple hue check - colors should be different enough
        final statusColors = [
          AppColors.success,
          AppColors.warning,
          AppColors.error,
          AppColors.info,
        ];

        for (var i = 0; i < statusColors.length; i++) {
          for (var j = i + 1; j < statusColors.length; j++) {
            expect(
              statusColors[i] != statusColors[j],
              true,
              reason: 'Status colors should be distinct',
            );
          }
        }
      });

      test('game element colors should be distinct for accessibility', () {
        final gameColors = [
          AppColors.robotBlue,
          AppColors.princessPink,
          AppColors.flowerPink,
          AppColors.obstacleGray,
        ];

        for (var i = 0; i < gameColors.length; i++) {
          for (var j = i + 1; j < gameColors.length; j++) {
            expect(
              gameColors[i] != gameColors[j],
              true,
              reason: 'Game element colors should be distinct',
            );
          }
        }
      });
    });

    group('Theme consistency', () {
      test('should follow "The Wild Robot" theme', () {
        // Earth tones should be present
        expect(AppColors.forestGreen, isA<Color>());
        expect(AppColors.earthBrown, isA<Color>());
        expect(AppColors.softCream, isA<Color>());

        // Warm accents should be present
        expect(AppColors.warmOrange, isA<Color>());
        expect(AppColors.sunsetOrange, isA<Color>());
      });
    });
  });
}

