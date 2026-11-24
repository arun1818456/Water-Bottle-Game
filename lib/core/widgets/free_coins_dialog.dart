import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../services/ads_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/number_formatter.dart';
import 'internet_required_dialog.dart';

/// Luxury Glassmorphic Dialog to earn free coins via Rewarded Video Ads
class FreeCoinsDialog extends StatefulWidget {
  const FreeCoinsDialog({super.key});

  @override
  State<FreeCoinsDialog> createState() => _FreeCoinsDialogState();
}

class _FreeCoinsDialogState extends State<FreeCoinsDialog> {
  final StorageService storage = StorageService.to;
  final AdsService ads = AdsService.to;

  bool _isWatchingAd = false;
  int _lastEarned = 0;
  bool _showRewardBanner = false;

  static const int rewardCoinsAmount = 150;

  @override
  void initState() {
    super.initState();
    // Ensure an ad is pre-fetched
    ads.preloadRewardedAd();
  }

  Future<void> _watchRewardedAd() async {
    if (_isWatchingAd) return;

    final hasInternet = await ads.checkInternetConnection();
    if (!hasInternet) {
      InternetRequiredDialog.show(
        title: 'Internet Required',
        message: 'An internet connection is required to earn free coins. Please connect to the internet and try again.',
      );
      return;
    }

    AudioService.to.playButtonClick();

    setState(() {
      _isWatchingAd = true;
      _showRewardBanner = false;
    });

    ads.showRewardedAd(
      customOfflineMessage: 'An internet connection is required to earn free coins. Please connect to the internet and try again.',
      onUserEarnedReward: (reward) async {
        if (!mounted) return;
        final amount = rewardCoinsAmount;
        await storage.addCoins(amount);
        AudioService.to.playWinSound();

        setState(() {
          _isWatchingAd = false;
          _lastEarned = amount;
          _showRewardBanner = true;
        });
      },
      onAdClosed: () {
        if (mounted) {
          setState(() {
            _isWatchingAd = false;
          });
        }
      },
      onAdFailed: () {
        if (mounted) {
          setState(() {
            _isWatchingAd = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D284E), Color(0xFF081A35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Coin Pill + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Coin Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14457F), Color(0xFF0B2B54)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Color(0xFFFFD700),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Obx(
                        () => Text(
                          storage.coins.value.formatCompact,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button
                GestureDetector(
                  onTap: () {
                    AudioService.to.playButtonClick();
                    Get.back();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Animated Coin Chest / Icon with Radial Glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing Glow
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Gradient Circle with Gold Coin
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFEA79), Color(0xFFFF9800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFF9C4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8F00).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.monetization_on_rounded,
                      size: 52,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.06, 1.06), duration: 1200.ms),
              ],
            ),

            const SizedBox(height: 16),

            // Dialog Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF80E5FF), Color(0xFFFFFFFF), Color(0xFFFFD54F)],
              ).createShader(bounds),
              child: const Text(
                'GET FREE COINS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle Description
            Text(
              'Watch a short video sponsor to earn +$rewardCoinsAmount gold coins instantly! Use coins to unlock exclusive bottles and themes in the shop.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),

            // Success Claim Banner
            if (_showRewardBanner) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Awesome! +$_lastEarned Coins Added!',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9)),
            ],

            const SizedBox(height: 22),

            // Big CTA Watch Ad Button
            GestureDetector(
              onTap: _isWatchingAd ? null : _watchRewardedAd,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isWatchingAd
                        ? [Colors.grey.shade700, Colors.grey.shade800]
                        : [const Color(0xFFFF9100), const Color(0xFFFF5722)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isWatchingAd
                        ? Colors.grey
                        : const Color(0xFFFFE082),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isWatchingAd
                              ? Colors.black26
                              : const Color(0xFFFF5722))
                          .withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isWatchingAd
                    ? const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Loading Video Ad...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'WATCH AD  •  +150 COINS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Shop Shortcut or Close
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                Get.toNamed('/shop');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 15,
                      color: Color(0xFF80D8FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Spend Coins in Cosmetic Shop',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF80D8FF).withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack);
  }
}
