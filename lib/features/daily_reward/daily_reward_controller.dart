import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class DailyRewardController extends GetxController {
  final storage = StorageService.to;
  bool _hasShownBrokenDialog = false;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowStreakBrokenDialog();
    });
  }

  void checkAndShowStreakBrokenDialog() {
    if (_hasShownBrokenDialog) return;
    if (storage.isStreakBroken()) {
      _hasShownBrokenDialog = true;
      _showStreakBrokenDialog();
    }
  }

  void _showStreakBrokenDialog() {
    Get.dialog(
      _StreakBrokenDialog(
        onStartFresh: () {
          AudioService.to.playButtonClick();
          // Reset streak so Day 1 becomes active to redeem
          storage.dailyStreak.value = 0;
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }

  int get currentClaimDay {
    final streak = storage.dailyStreak.value;
    if (streak <= 0) return 0;
    return (streak - 1) % 7;
  }

  int get nextClaimDay {
    final streak = storage.dailyStreak.value;
    final isClaimable = storage.isDailyRewardClaimable();
    if (isClaimable) {
      return streak % 7;
    }
    if (streak <= 0) return 0;
    return (streak - 1) % 7;
  }

  bool isDayClaimed(int dayIndex) {
    final streak = storage.dailyStreak.value;
    if (streak <= 0) return false;

    final isClaimable = storage.isDailyRewardClaimable();
    if (isClaimable) {
      final active = streak % 7;
      return dayIndex < active;
    } else {
      final lastClaimedIndex = (streak - 1) % 7;
      return dayIndex <= lastClaimedIndex;
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
      _DailyCelebrationDialog(earned: earned, storage: storage),
      barrierDismissible: true,
    );
  }
}

class _DailyCelebrationDialog extends StatefulWidget {
  final int earned;
  final StorageService storage;

  const _DailyCelebrationDialog({
    required this.earned,
    required this.storage,
  });

  @override
  State<_DailyCelebrationDialog> createState() => _DailyCelebrationDialogState();
}

class _DailyCelebrationDialogState extends State<_DailyCelebrationDialog> {
  bool _isDoubled = false;
  bool _isProcessingAd = false;

  void _onDoublePressed() {
    if (_isDoubled || _isProcessingAd) return;
    setState(() => _isProcessingAd = true);
    AudioService.to.playButtonClick();

    AdsService.to.showRewardedAd(
      onUserEarnedReward: (reward) {
        if (!mounted) return;
        setState(() {
          _isProcessingAd = false;
          _isDoubled = true;
        });
        StorageService.to.addCoins(widget.earned);
      },
      onAdClosed: () {
        if (mounted) setState(() => _isProcessingAd = false);
      },
      onAdFailed: () {
        if (mounted) setState(() => _isProcessingAd = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCoins = _isDoubled ? widget.earned * 2 : widget.earned;

    return Dialog(
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
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+$totalCoins COINS',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                if (_isDoubled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '2X',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Streak: ${widget.storage.dailyStreak.value} Days 🔥',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCyan,
              ),
            ),

            const SizedBox(height: 20),

            if (!_isDoubled) ...[
              GestureDetector(
                onTap: _isProcessingAd ? null : _onDoublePressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isProcessingAd
                          ? [Colors.grey, Colors.grey.shade700]
                          : [const Color(0xFFFF9100), const Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isProcessingAd ? Icons.hourglass_top_rounded : Icons.video_collection_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProcessingAd ? 'Loading Ad...' : 'Double Reward (2x)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

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
    );
  }
}

class _StreakBrokenDialog extends StatelessWidget {
  final VoidCallback onStartFresh;

  const _StreakBrokenDialog({required this.onStartFresh});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3D0C11), Color(0xFF1E0508)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFF5252).withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
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
            // Animated Glowing Sad Emoji Circle
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFD32F2F), Color(0xFF8B0000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '😢',
                  style: TextStyle(fontSize: 52),
                ),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .shake(delay: 350.ms, duration: 600.ms, hz: 4),

            const SizedBox(height: 20),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF8A8A), Color(0xFFFF3333)],
              ).createShader(bounds),
              child: const Text(
                'STREAK BROKEN!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5252), width: 1),
              ),
              child: const Text(
                'OH NO! DAY MISSED 💔',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8A8A),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'You missed a day and lost your daily streak progression! Don\'t worry, start fresh today with Day 1 reward.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: onStartFresh,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFC62828)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF8A8A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'OK, START FRESH (DAY 1)',
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }
}
