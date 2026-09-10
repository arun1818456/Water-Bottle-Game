import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class DailyRewardController extends GetxController {
  final storage = StorageService.to;

  int get currentClaimDay {
    if (storage.dailyStreak.value == 0) return 0;
    return (storage.dailyStreak.value - 1) % 7;
  }

  int get nextClaimDay {
    if (storage.isDailyRewardClaimable()) {
      return (storage.dailyStreak.value) % 7;
    }
    return (storage.dailyStreak.value - 1) % 7;
  }

  Future<void> claimTodayReward() async {
    if (!storage.isDailyRewardClaimable()) {
      Get.snackbar(
        'Already Claimed',
        'Come back tomorrow for your next reward!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    AudioService.to.playButtonClick();
    final earned = await storage.claimDailyReward();

    if (earned > 0) {
      AudioService.to.playWinSound();
      Get.snackbar(
        'Reward Claimed!',
        '+$earned Coins added to your balance!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: const Color(0xFFFFD700),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
