import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/constants/app_constants.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/leaderboard/leaderboard_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await Get.putAsync(() => StorageService().init());
  });

  group('Leaderboard Controller & Ranking Tests (Zero Dummy Data & Cached Cloud Architecture)', () {
    test('Guest user has zero static dummy data and prompts login', () {
      final controller = Get.put(LeaderboardController());

      // Guests must sign in with Google (no dummy data)
      expect(controller.isUserLoggedIn.value, isFalse);
      expect(controller.leaderboardUsers.isEmpty, isTrue);
      expect(controller.currentUserRank.value, equals(0));
    });

    test('Logged-in user with cached real Firebase users climbs rank offline when surpassing stars', () async {
      await StorageService.to.setUserEmail('player@gmail.com');
      // Cache real Firebase users in local storage
      await StorageService.to.saveCachedLeaderboard([
        LeaderboardUser(rank: 1, name: 'RealUser1', countryFlag: '🇮🇳', stars: 50, level: 18),
        LeaderboardUser(rank: 2, name: 'RealUser2', countryFlag: '🇺🇸', stars: 30, level: 11),
        LeaderboardUser(rank: 3, name: 'RealUser3', countryFlag: '🇮🇳', stars: 25, level: 9),
        LeaderboardUser(rank: 4, name: 'RealUser4', countryFlag: '🇬🇧', stars: 20, level: 7),
        LeaderboardUser(rank: 5, name: 'RealUser5', countryFlag: '🇮🇳', stars: 10, level: 4),
      ]);

      final controller = Get.put(LeaderboardController());
      await Future<void>.delayed(Duration.zero);

      expect(controller.isUserLoggedIn.value, isTrue);
      expect(controller.leaderboardUsers.length, equals(6));
      expect(controller.currentUserRank.value, equals(6));

      // Exact tie at 10 stars remains #6 (below 10-star user)
      final tieBoard = StorageService.to.getCachedLeaderboard(overrideUserStars: 10);
      expect(tieBoard.firstWhere((u) => u.isCurrentUser).rank, equals(6));

      // Earn 12 stars (> 10) -> overtakes RealUser5 (10 stars) and moves to #5
      for (var lvl = 1; lvl <= 4; lvl++) {
        await StorageService.to.completeLevel(lvl, 3);
      }
      await controller.refreshLeaderboard();

      expect(controller.userTotalStars.value, equals(12));
      expect(controller.currentUserRank.value, equals(5));
      expect(controller.hasRankClimbed.value, isTrue);
      expect(controller.previousUserRank.value, equals(6));
      expect(controller.leaderboardUsers[4].isCurrentUser, isTrue);
      expect(controller.leaderboardUsers[5].name, equals('RealUser5'));
    });

    test('Logged-in user without cached players falls back to single-user leaderboard', () async {
      await StorageService.to.setUserEmail('player@gmail.com');
      final starsMap = <int, int>{};
      for (var i = 1; i <= AppConstants.totalHandcraftedLevels; i++) {
        starsMap[i] = 3;
      }
      StorageService.to.levelStars.assignAll(starsMap);

      final controller = Get.put(LeaderboardController());
      await Future<void>.delayed(Duration.zero);

      expect(controller.isUserLoggedIn.value, isTrue);
      expect(controller.userTotalStars.value, equals(AppConstants.totalHandcraftedLevels * 3));
      expect(controller.leaderboardUsers.length, equals(1));
      expect(controller.currentUserRank.value, equals(1));
      expect(controller.leaderboardUsers.first.isCurrentUser, isTrue);
    });
  });
}
