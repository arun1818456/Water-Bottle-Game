import 'package:water_bottle_ais/exports.dart';

/// Main Menu Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final storage = controller.storage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGround),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Coins & Streak
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔥 Daily Streak Badge
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF14529B),
                              Color(0xFF0B3B80),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(
                            color: const Color(0xFF20D9FF),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00CFFF)
                                  .withValues(alpha: 0.18),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            // Flame Circle
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF082D69),
                                border: Border.all(
                                  color: const Color(0xFF164F9C),
                                ),
                              ),
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: Color(0xFFFF5722),
                                size: 15,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              '${storage.dailyStreak.value} Day Streak',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Right Arrow
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF38DFFF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🪙 Coins Counter
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 6,
                          bottom: 6,
                          right: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF14529B),
                              Color(0xFF0B3B80),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(
                            color: const Color(0xFF20D9FF),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00CFFF)
                                  .withValues(alpha: 0.18),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Coin Icon
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD700),
                                border: Border.all(
                                  color: const Color(0xFFFFE66D),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFFFFA000),
                                size: 20,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              '${storage.coins.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Plus Button
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF0752C7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border.all(
                                  color: const Color(0xFF40DFFF),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Game Hero Branding
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(5),
                  width: 50,
                  height: 50,
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
              ),

              const Spacer(flex: 6),

              // Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: GestureDetector(
                  onTap: controller.onPlayPressed,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF18DDF5),
                          Color(0xFF0795F5),
                          Color(0xFF0875E8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: const Color(0xFF39E9FF),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00CFFF)
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Color(0xFF064DA5),
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PLAY NOW',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 15),
              Obx(() => Text(
                'Current Level ${storage.unlockedLevel.value}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              )),
              const SizedBox(height: 15),

              // Action Buttons Row: Levels, Shop, Daily, Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMenuCard(
                      icon: Icons.grid_view_rounded,
                      label: 'Levels',
                      color: AppColors.primaryCyan,
                      onTap: controller.onLevelSelectPressed,
                    ),

                    _buildMenuCard(
                      icon: Icons.storefront_rounded,
                      label: 'Shop',
                      color: const Color(0xFFFFD700),
                      onTap: controller.onShopPressed,
                    ),

                    Obx(() {
                      final claimable =
                      storage.isDailyRewardClaimable();

                      return _buildMenuCard(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Daily',
                        color: const Color(0xFFFF4081),
                        hasBadge: claimable,
                        onTap: controller.onDailyRewardPressed,
                      );
                    }),

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
      child: SizedBox(
        width: 76,
        height: 92,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1B5DA5),
                Color(0xFF0B3679),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF28D9FF),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001C52)
                    .withValues(alpha: 0.35),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF092E68),
                      border: Border.all(
                        color: color.withValues(alpha: 0.65),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: 70,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (hasBadge)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF1744),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
