import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:water_bottle_ais/core/constants/app_images.dart';
import '../../core/services/audio_service.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/widgets/free_coins_dialog.dart';
import '../../core/widgets/google_features_dialog.dart';
import 'home_controller.dart';
import 'widgets/home_cartoon_widgets.dart';

/// Main Menu Screen
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    _checkAndShowGooglePromo();
  }

  void _checkAndShowGooglePromo() {
    final storage = controller.storage;
    final isLoggedIn = storage.userEmail.value.isNotEmpty;
    final alreadyShown = storage.hasGooglePromoBeenShown();

    // Pehli baar aane par aur agar user abhi tak Google se logged in nahi hai
    if (!alreadyShown && !isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Mark as shown so it appears strictly once
        await storage.setGooglePromoShown();
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 650));
          if (mounted && !storage.userEmail.value.isNotEmpty) {
            Get.dialog(
              const GoogleFeaturesDialog(),
              barrierDismissible: true,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = controller.storage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGround),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Streak (left) & Coins (right)
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 12,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Streak Badge
                    Obx(
                      () => CartoonStreakBadge(
                        streak: storage.dailyStreak.value,
                        isBroken: storage.isStreakBroken(),
                        onTap: controller.onDailyRewardPressed,
                      ),
                    ),

                    // Coins Pill
                    Obx(
                      () => CartoonCoinsBadge(
                        formattedCoins: storage.coins.value.formatCompact,
                        onTap: () {
                          AudioService.to.playButtonClick();
                          Get.dialog(
                            const FreeCoinsDialog(),
                            barrierDismissible: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Shifted Upper Leaderboard Pill
              Padding(
                padding: const EdgeInsets.only(right: 14, top: 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CartoonLeaderboardPill(
                    onTap: controller.onLeaderboardPressed,
                  ),
                ),
              ),

              // Open middle canvas showcasing background_image2.png logo & bottles
              const Spacer(),

              // Main Play CTA Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 276),
                  child: CartoonPlayNowButton(
                    onTap: controller.onPlayPressed,
                  )
                      .animate(autoPlay: !Get.testMode)
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .animate(
                        autoPlay: !Get.testMode,
                        onPlay: Get.testMode ? null : (c) => c.repeat(),
                      )
                      .shimmer(
                        delay: 2600.ms,
                        duration: 1300.ms,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                ),
              ),

              const SizedBox(height: 5),

              Obx(
                () => Text(
                  'Current Level ${storage.unlockedLevel.value}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: cartoonTextOutline(
                      strokeColor: const Color(0xFF04265E),
                      strokeWidth: 1.3,
                      shadowOffsetY: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons Row: Levels, Shop, Daily, Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: CartoonMenuCard(
                        label: 'Levels',
                        iconType: CartoonMenuIconType.levels,
                        onTap: controller.onLevelSelectPressed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CartoonMenuCard(
                        label: 'Shop',
                        iconType: CartoonMenuIconType.shop,
                        onTap: controller.onShopPressed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => CartoonMenuCard(
                          label: 'Daily',
                          iconType: CartoonMenuIconType.daily,
                          hasBadge: storage.isDailyRewardClaimable(),
                          onTap: controller.onDailyRewardPressed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CartoonMenuCard(
                        label: 'Settings',
                        iconType: CartoonMenuIconType.settings,
                        onTap: controller.onSettingsPressed,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // AdMob Banner at bottom of home screen
              controller.ads.getHomeBannerWidget(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  /// Show exit confirmation dialog on back press
  Future<void> _showExitDialog() async {
    AudioService.to.playButtonClick();
    HapticFeedbackHelper.selectionClick();

    final shouldExit = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E223D),
                Color(0xFF071324),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 24,
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
                  border: Border.all(
                    color: const Color(0xFFFF5252),
                    width: 1.8,
                  ),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Color(0xFFFF8A8A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Exit Game?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to quit Water Sort Puzzle?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AudioService.to.playButtonClick();
                        Get.back(result: false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
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
                            'Stay',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF001E3C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AudioService.to.playButtonClick();
                        Get.back(result: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Exit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF8A8A),
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
        ).animate().scale(duration: 240.ms, curve: Curves.easeOutBack).fadeIn(duration: 180.ms),
      ),
      barrierDismissible: true,
    );

    if (shouldExit == true) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await SystemNavigator.pop();
      }
    }
  }
}
