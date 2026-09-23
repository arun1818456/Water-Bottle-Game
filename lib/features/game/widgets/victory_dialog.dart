import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_theme.dart';

/// Victory celebration popup modal
class VictoryDialog extends StatefulWidget {
  final int levelId;
  final int stars;
  final int baseCoins;
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final bool showNextLevel;
  final bool showReplay;
  final String homeLabel;
  final String title;
  final String subtitle;

  const VictoryDialog({
    super.key,
    required this.levelId,
    required this.stars,
    required this.baseCoins,
    required this.onNextLevel,
    required this.onRestart,
    required this.onHome,
    this.showNextLevel = true,
    this.showReplay = true,
    this.homeLabel = 'Levels',
    this.title = 'VICTORY!',
    String? subtitle,
  }) : subtitle = subtitle ?? 'Level $levelId Cleared';

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> {
  final bool _doubleCoinsClaimed = false;
  late int _totalEarnedCoins;

  @override
  void initState() {
    super.initState();
    _totalEarnedCoins = widget.baseCoins;
  }

  void _onDoubleCoinsPressed() {
    if (_doubleCoinsClaimed) return;
    AudioService.to.playButtonClick();

    // AdsService.to.showRewardedAd(
    //   onUserEarnedReward: (reward) {
    //     setState(() {
    //       _doubleCoinsClaimed = true;
    //       final extraCoins = widget.baseCoins;
    //       _totalEarnedCoins += extraCoins;
    //       StorageService.to.addCoins(extraCoins);
    //     });
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid.withAlpha(245),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryCyan.withAlpha(120), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withAlpha(60),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
              ).createShader(bounds),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 8),

            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // Stars Row (1 to 3 animated stars)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isEarned = index < widget.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.star_rounded,
                    size: 48,
                    color: isEarned ? const Color(0xFFFFD700) : Colors.white24,
                  )
                      .animate(delay: (200 + index * 180).ms)
                      .scale(duration: 350.ms, curve: Curves.easeOutBack),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Coins earned badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: AppTheme.glassBox(
                color: AppColors.glassFillHeavy,
                borderRadius: 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$_totalEarnedCoins Coins',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Double Coins Button
            if (!_doubleCoinsClaimed)
              GestureDetector(
                onTap: _onDoubleCoinsPressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9100), Color(0xFFFF5722)],
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_collection_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Double Coins (2x)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.97, 0.97),
                    end: const Offset(1.03, 1.03),
                    duration: 800.ms,
                  ),

            const SizedBox(height: 14),

            // Next Level Button
            if (widget.showNextLevel)
              GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                widget.onNextLevel();
              },
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: AppTheme.gradientButtonBox(),
                child: const Center(
                  child: Text(
                    'NEXT LEVEL',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002244),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ),
              ),

            SizedBox(height: widget.showNextLevel ? 12 : 0),

            // Restart & Level Select Row
            Row(
              children: [
                if (widget.showReplay)
                  Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      AudioService.to.playButtonClick();
                      Get.back();
                      widget.onRestart();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.white),
                    label: const Text('Replay', style: TextStyle(color: Colors.white)),
                  ),
                ),
                if (widget.showReplay) const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      AudioService.to.playButtonClick();
                      Get.back();
                      widget.onHome();
                    },
                    icon: const Icon(Icons.grid_view_rounded, size: 18, color: Colors.white),
                    label: Text(widget.homeLabel, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
