import 'package:water_bottle_ais/exports.dart';

class HomeController extends GetxController {
  final storage = StorageService.to;

  void onPlayPressed() {
    AudioService.to.playButtonClick();
    final targetLevel = storage.unlockedLevel.value;
    Get.toNamed(AppRoutes.gameScreen, arguments: {'levelId': targetLevel});
  }

  void onLevelSelectPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed(AppRoutes.levelSelectScreen);
  }

  void onShopPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed(AppRoutes.shopScreen);
  }

  void onDailyRewardPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed(AppRoutes.dailyRewardScreen);
  }

  void onSettingsPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed(AppRoutes.settingsScreen);
  }
}
