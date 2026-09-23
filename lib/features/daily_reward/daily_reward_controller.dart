import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class DailyRewardController extends GetxController {
  final storage = StorageService.to;

  int get currentClaimDay {
    final streak = storage.dailyStreak.value;
    if (streak == 0) return 0;
    return (streak - 1) % 7;
  }

  int get nextClaimDay {
    final streak = storage.dailyStreak.value;
    final isClaimable = storage.isDailyRewardClaimable();
    if (isClaimable) {
      return streak % 7;
    }
    return (streak - 1) % 7;
  }

  bool isDayClaimed(int dayIndex) {
    final streak = storage.dailyStreak.value;
    final isClaimable = storage.isDailyRewardClaimable();
    if (isClaimable) {
      final active = streak % 7;
      return dayIndex < active;
    } else {
      final claimed = (streak - 1) % 7;
      return dayIndex <= claimed;
    }
  }

  bool isDayReadyToClaim(int dayIndex) {
    final streak = storage.dailyStreak.value;
    final isClaimable = storage.isDailyRewardClaimable();
    if (!isClaimable) return false;
    final active = streak % 7;
    return dayIndex == active;
  }

  int get todayRewardAmount {
    final idx = nextClaimDay;
    if (idx >= 0 && idx < AppConstants.dailyRewards.length) {
      return AppConstants.dailyRewards[idx];
    }
    return AppConstants.dailyRewards[0];
  }

  Future<void> claimTodayReward() async {
    if (!storage.isDailyRewardClaimable()) {
      Get.snackbar(
        'Already Claimed',
        'Come back tomorrow for your next reward!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    AudioService.to.playButtonClick();
    final earned = await storage.claimDailyReward();

    if (earned > 0) {
      AudioService.to.playWinSound();
      _showCelebrationDialog(earned);
    }
  }

  void _showCelebrationDialog(int earned) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF132F5C), Color(0xFF0B1A34)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing coin badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFEA79), Color(0xFFFF9800), Color(0xFFE65100)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      blurRadius: 25,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shimmer(delay: 300.ms, duration: 1000.ms),

              const SizedBox(height: 20),

              const Text(
                'REWARD CLAIMED!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '+$earned COINS',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Streak: ${storage.dailyStreak.value} Days 🔥',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryCyan,
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF80D8FF),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AWESOME!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
