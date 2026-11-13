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

  group('Leaderboard Controller & Ranking Tests (Zero Static Data & Cloud Architecture)', () {
    test('Guest user has zero static dummy data and prompts login', () {
      final controller = Get.put(LeaderboardController());

      // Under new rule: No dummy/static data when not logged in!
      expect(controller.isUserLoggedIn.value, isFalse);
      expect(controller.leaderboardUsers.isEmpty, isTrue);
      expect(controller.currentUserRank.value, equals(0));
    });

    test('Logged-in user loads dynamic leaderboard with valid rank and stars', () async {
      // Simulate logged in user
      await StorageService.to.setUserEmail('player@gmail.com');
      final starsMap = <int, int>{};
      for (var i = 1; i <= AppConstants.totalHandcraftedLevels; i++) {
        starsMap[i] = 3;
      }
      StorageService.to.levelStars.assignAll(starsMap);

      final controller = Get.put(LeaderboardController());
      expect(controller.isUserLoggedIn.value, isTrue);
      expect(controller.userTotalStars.value, equals(AppConstants.totalHandcraftedLevels * 3));
      expect(controller.leaderboardUsers.isNotEmpty, isTrue);
      expect(controller.currentUserRank.value, equals(1)); // #1 rank
      expect(controller.leaderboardUsers.first.isCurrentUser, isTrue);
    });
  });
}
