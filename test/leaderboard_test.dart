import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/leaderboard/leaderboard_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await Get.putAsync(() => StorageService().init());
  });

  group('Leaderboard Controller & Ranking Tests', () {
    test('Leaderboard users are sorted by stars in descending order', () {
      final controller = Get.put(LeaderboardController());
      final list = controller.leaderboardUsers;

      expect(list.length, greaterThanOrEqualTo(10));

      for (var i = 0; i < list.length - 1; i++) {
        expect(list[i].stars, greaterThanOrEqualTo(list[i + 1].stars));
        expect(list[i].rank, equals(i + 1));
      }
    });

    test('Current user rank updates dynamically based on total stars', () {
      final starsMap = <int, int>{};
      for (var i = 1; i <= 400; i++) {
        starsMap[i] = 3;
      }
      StorageService.to.levelStars.assignAll(starsMap);

      final controller = Get.put(LeaderboardController());
      expect(controller.userTotalStars.value, equals(1200));
      expect(controller.currentUserRank.value, equals(1)); // #1 rank
    });
  });
}
