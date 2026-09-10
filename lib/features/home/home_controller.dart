import 'package:get/get.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final storage = StorageService.to;
  final ads = AdsService.to;

  @override
  void onInit() {
    super.onInit();
    ads.loadHomeBanner();
  }

  void onPlayPressed() {
    AudioService.to.playButtonClick();
    final targetLevel = storage.unlockedLevel.value;
    Get.toNamed('/game', arguments: {'levelId': targetLevel});
  }

  void onLevelSelectPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed('/levels');
  }

  void onShopPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed('/shop');
  }

  void onDailyRewardPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed('/daily-reward');
  }

  void onSettingsPressed() {
    AudioService.to.playButtonClick();
    Get.toNamed('/settings');
  }
}
