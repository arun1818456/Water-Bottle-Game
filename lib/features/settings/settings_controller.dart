import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final storage = StorageService.to;
  final RxString versionString = AppConstants.appVersion.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      versionString.value = '${info.version}+${info.buildNumber}';
    } catch (_) {
      versionString.value = AppConstants.appVersion;
    }
  }

  void toggleSound(bool val) {
    AudioService.to.playButtonClick();
    storage.setSoundEnabled(val);
  }

  void toggleMusic(bool val) {
    AudioService.to.playButtonClick();
    storage.setMusicEnabled(val);
  }

  void toggleVibration(bool val) {
    AudioService.to.playButtonClick();
    storage.setVibrationEnabled(val);
  }

  void confirmResetProgress() {
    AudioService.to.playButtonClick();
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will permanently reset your unlocked levels, coins, and purchased skins. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await storage.resetAll();
              Get.back();
              Get.snackbar(
                'Progress Reset',
                'Game progress has been successfully reset.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void showPrivacyPolicy() {
    AudioService.to.playButtonClick();
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Aqua Sort Master is committed to protecting your privacy.\n\n'
            '• Local Data: Game state, levels, coins, and settings are stored locally on your device.\n'
            '• Advertisements: Google Mobile Ads (AdMob) may collect anonymous device identifiers to serve non-personalized and personalized ads in accordance with Google\'s privacy policy.\n'
            '• Analytics: No sensitive personal data is collected or shared.\n\n'
            'For any questions or privacy concerns, please contact support@aquasortmaster.game',
            style: TextStyle(height: 1.4, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void rateApp() {
    AudioService.to.playButtonClick();
    Get.snackbar(
      'Thank You!',
      'Redirecting to app store review...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: const Color(0xFFFFD700),
    );
  }

  void shareApp() {
    AudioService.to.playButtonClick();
    Get.snackbar(
      'Share Aqua Sort Master',
      'Invite your friends to beat Level 120!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }
}
