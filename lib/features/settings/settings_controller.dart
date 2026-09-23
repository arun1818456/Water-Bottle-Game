import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
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
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1020), Color(0xFF0F0B18)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withValues(alpha: 0.25),
                blurRadius: 20,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFF5252), width: 1.5),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFFF5252),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset Progress?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This will permanently clear all your unlocked levels, earned coins, and custom skins. Are you sure you want to proceed?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await storage.resetAll();
                        Get.back();
                        Get.snackbar(
                          'Progress Reset',
                          'Game progress has been successfully reset.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFD50000)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Reset All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPrivacyPolicy() {
    AudioService.to.playButtonClick();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E223D), Color(0xFF071324)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 20,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Color(0xFF00E5FF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Flexible(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Text(
                    '${AppConstants.appName} is committed to protecting your privacy.\n\n'
                    '• Local Data: Game state, levels, coins, and settings are stored locally on your device.\n\n'
                    '• Advertisements: Google Mobile Ads (AdMob) may collect anonymous device identifiers to serve non-personalized and personalized ads in accordance with Google\'s privacy policy.\n\n'
                    '• Analytics: No sensitive personal data is collected or shared.\n\n'
                    'For any questions or privacy concerns, please contact aruninnovationstudio@gmail.com',
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'I Understand',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateApp() async {
    AudioService.to.playButtonClick();
    final marketUri = Uri.parse('market://details?id=com.aruninnovationstudio.water_bottle_ais');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=com.aruninnovationstudio.water_bottle_ais');
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open the Play Store',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open the Play Store: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
        colorText: Colors.white,
      );
    }
  }

  Future<void> rateApp() async {
    AudioService.to.playButtonClick();
    final marketUri = Uri.parse('market://details?id=com.aruninnovationstudio.water_bottle_ais');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=com.aruninnovationstudio.water_bottle_ais');

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Rate App',
          'Could not open the Play Store page.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Rate App',
        'Could not open the Play Store: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
        colorText: Colors.white,
      );
    }
  }

  Future<void> shareApp() async {
    AudioService.to.playButtonClick();
    const shareText = '🎮 Play AIS Water Bottle - The ultimate water pouring and sorting puzzle game! 💧🧪\n\n'
        'Download now on Google Play Store:\n'
        'https://play.google.com/store/apps/details?id=com.aruninnovationstudio.water_bottle_ais\n\n'
        'Can you beat Level 120? Challenge your friends! 🏆';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'Play AIS Water Bottle Puzzle Game!',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Share',
        'Could not open share dialog: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
        colorText: Colors.white,
      );
    }
  }
}
