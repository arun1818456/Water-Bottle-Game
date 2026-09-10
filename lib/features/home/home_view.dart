import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'home_controller.dart';
import 'widgets/interactive_water_drop.dart';

/// Main Menu Screen
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final storage = controller.storage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundMid, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Coins & Streak
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Daily Streak Badge with Flame Icon
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: AppTheme.glassBox(borderRadius: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: Color(0xFFFF5722),
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${storage.dailyStreak.value} Day Streak',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),

                    // Coins Counter Pill
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: AppTheme.glassBox(
                            color: AppColors.glassFillHeavy,
                            borderRadius: 18,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFFFFD700),
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${storage.coins.value}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Game Hero Branding
              Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryCyan, AppColors.primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryCyan.withAlpha(120),
                          blurRadius: 36,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const InteractiveWaterDrop(),
                  )
                      .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
                      .moveY(begin: -6, end: 6, duration: 1800.ms, curve: Curves.easeInOut),

                  const SizedBox(height: 20),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryCyan, Color(0xFF80D8FF), Colors.white],
                    ).createShader(bounds),
                    child: const Text(
                      'AQUA SORT MASTER',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Obx(() => Text(
                        'Level ${storage.unlockedLevel.value}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      )),
                ],
              ),

              const Spacer(flex: 2),

              // Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: controller.onPlayPressed,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: AppTheme.gradientButtonBox(
                      colors: [AppColors.primaryCyan, AppColors.primaryBlue],
                      borderRadius: 22,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Color(0xFF002244), size: 36),
                        SizedBox(width: 8),
                        Text(
                          'PLAY NOW',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF002244),
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              // Action Buttons Row: Levels, Shop, Daily, Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Levels
                    _buildMenuCard(
                      icon: Icons.grid_view_rounded,
                      label: 'Levels',
                      color: AppColors.primaryCyan,
                      onTap: controller.onLevelSelectPressed,
                    ),

                    // Shop
                    _buildMenuCard(
                      icon: Icons.storefront_rounded,
                      label: 'Shop',
                      color: const Color(0xFFFFD700),
                      onTap: controller.onShopPressed,
                    ),

                    // Daily Reward
                    Obx(() {
                      final claimable = storage.isDailyRewardClaimable();
                      return _buildMenuCard(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Daily',
                        color: const Color(0xFFFF4081),
                        hasBadge: claimable,
                        onTap: controller.onDailyRewardPressed,
                      );
                    }),

                    // Settings
                    _buildMenuCard(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      color: AppColors.primaryPurple,
                      onTap: controller.onSettingsPressed,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // AdMob Banner at bottom of home screen
              controller.ads.getHomeBannerWidget(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72,
            height: 76,
            decoration: AppTheme.glassBox(
              color: AppColors.glassFillHeavy,
              borderRadius: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (hasBadge)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF1744),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 600.ms,
                  ),
            ),
        ],
      ),
    );
  }
}
