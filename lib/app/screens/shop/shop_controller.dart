import 'package:water_bottle_ais/exports.dart';

class ShopController extends GetxController {
  final storage = StorageService.to;
  final RxInt selectedTab = 0.obs; // 0 = Bottles, 1 = Backgrounds

  void selectTab(int index) {
    AudioService.to.playButtonClick();
    selectedTab.value = index;
  }

  Future<void> onBottleAction(BottleSkinType skin) async {
    AudioService.to.playButtonClick();

    final isUnlocked = storage.unlockedBottleSkins.contains(skin.name);
    if (isUnlocked) {
      await storage.equipBottleSkin(skin.name);
      Get.snackbar(
        'Equipped!',
        '${skin.title} is now active.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      final success = await storage.buyAndUnlockBottleSkin(skin);
      if (success) {
        AudioService.to.playWinSound();
        Get.snackbar(
          'Unlocked!',
          'You unlocked ${skin.title}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Not Enough Coins',
          'Complete more levels to earn coins!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(200),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> onBackgroundAction(BackgroundThemeType bg) async {
    AudioService.to.playButtonClick();

    final isUnlocked = storage.unlockedBackgrounds.contains(bg.name);
    if (isUnlocked) {
      await storage.equipBackground(bg.name);
      Get.snackbar(
        'Equipped!',
        '${bg.title} background is now active.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      final success = await storage.buyAndUnlockBackground(bg);
      if (success) {
        AudioService.to.playWinSound();
        Get.snackbar(
          'Unlocked!',
          'You unlocked ${bg.title}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Not Enough Coins',
          'Complete more levels to earn coins!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(200),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}
