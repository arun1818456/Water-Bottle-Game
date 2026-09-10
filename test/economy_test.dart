import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/core/constants/app_constants.dart';

void main() {
  group('Economy & Rewards Tests', () {
    test('Daily rewards match 7-day progression', () {
      expect(AppConstants.dailyRewards.length, equals(7));
      expect(AppConstants.dailyRewards[0], equals(50));  // Day 1
      expect(AppConstants.dailyRewards[1], equals(75));  // Day 2
      expect(AppConstants.dailyRewards[2], equals(100)); // Day 3
      expect(AppConstants.dailyRewards[3], equals(150)); // Day 4
      expect(AppConstants.dailyRewards[4], equals(200)); // Day 5
      expect(AppConstants.dailyRewards[5], equals(300)); // Day 6
      expect(AppConstants.dailyRewards[6], equals(500)); // Day 7
    });

    test('Star bonuses are properly tiered', () {
      expect(AppConstants.coinsFor3Stars, greaterThan(AppConstants.coinsFor2Stars));
      expect(AppConstants.coinsFor2Stars, greaterThan(AppConstants.coinsFor1Star));
    });

    test('Bottle skin items have valid non-negative pricing', () {
      for (final skin in BottleSkinType.values) {
        expect(skin.price, greaterThanOrEqualTo(0));
        expect(skin.title.isNotEmpty, isTrue);
      }
    });

    test('Background theme items have valid non-negative pricing', () {
      for (final bg in BackgroundThemeType.values) {
        expect(bg.price, greaterThanOrEqualTo(0));
        expect(bg.title.isNotEmpty, isTrue);
      }
    });
  });
}
