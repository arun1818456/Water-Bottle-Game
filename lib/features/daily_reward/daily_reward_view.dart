import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'daily_reward_controller.dart';

/// 7-Day Daily Reward and Streak screen
class DailyRewardView extends StatelessWidget {
  const DailyRewardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyRewardController());
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
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    const Text(
                      'DAILY REWARD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Streak Pill
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: AppTheme.glassBox(borderRadius: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF5722), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${storage.dailyStreak.value} Days',
                                style: const TextStyle(
                                  fontSize: 13,
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

              const SizedBox(height: 12),

              // Streak Flame Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: AppTheme.glassBox(
                  color: AppColors.glassFillHeavy,
                  borderRadius: 24,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFF5722),
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                '${storage.dailyStreak.value} Consecutive Days',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )),
                          const SizedBox(height: 4),
                          const Text(
                            'Play every day to earn increasing coin rewards!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 7 Day Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() {
                    final isClaimable = storage.isDailyRewardClaimable();
                    final activeDay = controller.nextClaimDay;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final rewardCoins = AppConstants.dailyRewards[index];
                        final isToday = isClaimable && (index == activeDay);
                        final isClaimed = !isClaimable && (index <= controller.currentClaimDay);

                        return _buildDayCard(
                          dayNumber: index + 1,
                          coins: rewardCoins,
                          isToday: isToday,
                          isClaimed: isClaimed,
                        );
                      },
                    );
                  }),
                ),
              ),

              // Claim Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Obx(() {
                  final canClaim = storage.isDailyRewardClaimable();

                  return GestureDetector(
                    onTap: canClaim ? () => controller.claimTodayReward() : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: canClaim
                          ? AppTheme.gradientButtonBox(
                              colors: [const Color(0xFFFFD700), const Color(0xFFFF9100)],
                            )
                          : BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(18),
                            ),
                      child: Center(
                        child: Text(
                          canClaim ? 'CLAIM TODAY\'S REWARD' : 'ALREADY CLAIMED TODAY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: canClaim ? const Color(0xFF002244) : Colors.white38,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard({
    required int dayNumber,
    required int coins,
    required bool isToday,
    required bool isClaimed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFFFFD700).withAlpha(50)
            : (isClaimed ? Colors.white.withAlpha(15) : AppColors.glassFill),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFD700)
              : (isClaimed ? Colors.white24 : AppColors.glassBorder),
          width: isToday ? 2.0 : 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Day $dayNumber',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isToday ? const Color(0xFFFFD700) : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            isClaimed ? Icons.check_circle_rounded : Icons.monetization_on_rounded,
            color: isClaimed
                ? AppColors.accentNeonGreen
                : (isToday ? const Color(0xFFFFD700) : Colors.white38),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '+$coins',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isClaimed ? Colors.white54 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
