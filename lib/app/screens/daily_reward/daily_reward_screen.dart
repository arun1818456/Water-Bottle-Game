import 'package:water_bottle_ais/exports.dart';

/// Modern 7-Day Daily Reward and Streak screen
class DailyRewardScreen extends StatelessWidget {
  const DailyRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyRewardController());

    return Scaffold(
      body: Stack(
        children: [
          // Background with rich ambient overlay
          Positioned.fill(
            child: Image.asset(
              AppImages.backGround,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF07152B).withValues(alpha: 0.90),
                    const Color(0xFF091F3D).withValues(alpha: 0.94),
                    const Color(0xFF050E1B).withValues(alpha: 0.97),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              final streak = controller.storage.dailyStreak.value;
              final coins = controller.storage.coins.value;
              final isClaimable = controller.storage.isDailyRewardClaimable();
              final todayReward = controller.todayRewardAmount;

              return Column(
                children: [
                  // Top Header Bar
                  _buildTopBar(context, coins),

                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Streak Hero Progress Card
                          _buildStreakHero(controller, streak, isClaimable),

                          const SizedBox(height: 18),

                          // Section Title
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '7-DAY REWARD CALENDAR',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 12),

                          // Days 1 to 6 Grid (2 rows of 3)
                          _buildDaysGrid(controller),

                          const SizedBox(height: 12),

                          // Day 7 Mega Grand Reward Card (Full Width)
                          _buildDay7MegaCard(controller),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Claim Action Bar
                  _buildBottomActionBar(controller, isClaimable, todayReward),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Top bar with back button, screen title, and coin balance
  Widget _buildTopBar(BuildContext context, int coins) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Glass Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2A52).withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E60A8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // Title
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF80E5FF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFD54F),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'DAILY REWARDS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'Log in every day for free coins',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Coins Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14457F), Color(0xFF0B2B54)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFD700),
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  '$coins',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Streak Hero Card with 7-Day milestone indicator
  Widget _buildStreakHero(DailyRewardController controller, int streak, bool isClaimable) {
    final activeCycleDay = isClaimable ? (streak % 7) : ((streak - 1) % 7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF103362), Color(0xFF091F3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF268AFF).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Glowing Flame Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFD84315)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              )
                  .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.06, 1.06), duration: 1200.ms),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$streak Day Streak',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF7043),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isClaimable ? 'READY' : 'ACTIVE',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A65),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isClaimable
                          ? 'Claim today\'s prize to keep your streak going!'
                          : 'Streak saved! Come back tomorrow for Day ${((streak) % 7) + 1} reward.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 7-Day Milestone Step Tracker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF061426).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isDone = controller.isDayClaimed(index);
                final isCurrent = controller.isDayReadyToClaim(index) ||
                    (!isClaimable && index == activeCycleDay);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF00E676)
                            : (isCurrent
                                ? const Color(0xFFFFD700)
                                : Colors.white.withValues(alpha: 0.08)),
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFF69F0AE)
                              : (isCurrent
                                  ? Colors.white
                                  : Colors.white24),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : (isDone
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 16, color: Color(0xFF00381A))
                            : (isCurrent
                                ? const Icon(Icons.star_rounded, size: 16, color: Color(0xFF5D3F00))
                                : Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'D${index + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent
                            ? const Color(0xFFFFD700)
                            : (isDone ? const Color(0xFF69F0AE) : Colors.white38),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  /// Grid of 6 Days (Days 1 - 6)
  Widget _buildDaysGrid(DailyRewardController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final rewardCoins = AppConstants.dailyRewards[index];
        final isClaimed = controller.isDayClaimed(index);
        final isToday = controller.isDayReadyToClaim(index);

        return _buildDayCard(
          dayNumber: index + 1,
          coins: rewardCoins,
          isToday: isToday,
          isClaimed: isClaimed,
          index: index,
        );
      },
    );
  }

  /// Individual Day Card (for Days 1 to 6)
  Widget _buildDayCard({
    required int dayNumber,
    required int coins,
    required bool isToday,
    required bool isClaimed,
    required int index,
  }) {
    Widget card = Container(
      decoration: BoxDecoration(
        gradient: isToday
            ? const LinearGradient(
                colors: [Color(0xFF284C7E), Color(0xFF142F54)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : (isClaimed
                ? LinearGradient(
                    colors: [
                      const Color(0xFF09182C).withValues(alpha: 0.8),
                      const Color(0xFF06101E).withValues(alpha: 0.9),
                    ],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0F2B50), Color(0xFF0A1E38)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFD700)
              : (isClaimed
                  ? const Color(0xFF00E676).withValues(alpha: 0.4)
                  : const Color(0xFF1F589A).withValues(alpha: 0.4)),
          width: isToday ? 2.0 : 1.2,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        children: [
          if (isToday)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFFFFD700)
                        : (isClaimed
                            ? const Color(0xFF00E676).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Day $dayNumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isToday
                          ? const Color(0xFF3E2700)
                          : (isClaimed ? const Color(0xFF69F0AE) : Colors.white70),
                    ),
                  ),
                ),

                Center(
                  child: isClaimed
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFF00E676),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF00E676),
                            size: 24,
                          ),
                        )
                      : (isToday
                          ? Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFFFFEA79), Color(0xFFFF9800)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.monetization_on_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFFFC107),
                              size: 34,
                            )),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+$coins',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isToday
                            ? const Color(0xFFFFD700)
                            : (isClaimed ? Colors.white38 : Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isClaimed)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00E676),
                ),
                child: const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );

    if (isToday) {
      return card
          .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: 1000.ms)
          .shimmer(delay: 500.ms, duration: 1200.ms);
    }

    return card.animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  /// Day 7 Grand Mega Card (Full width horizontal hero card)
  Widget _buildDay7MegaCard(DailyRewardController controller) {
    final isClaimed = controller.isDayClaimed(6);
    final isToday = controller.isDayReadyToClaim(6);
    const coins = 500;

    Widget megaCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: isToday
            ? const LinearGradient(
                colors: [
                  Color(0xFF7B1FA2),
                  Color(0xFFE65100),
                  Color(0xFFFFB300),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : (isClaimed
                ? LinearGradient(
                    colors: [
                      const Color(0xFF0E223D).withValues(alpha: 0.85),
                      const Color(0xFF081424).withValues(alpha: 0.95),
                    ],
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFF311B92),
                      Color(0xFF1A237E),
                      Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFD700)
              : (isClaimed
                  ? const Color(0xFF00E676).withValues(alpha: 0.4)
                  : const Color(0xFF7C4DFF).withValues(alpha: 0.7)),
          width: isToday ? 2.2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday
                ? const Color(0xFFFF9800).withValues(alpha: 0.45)
                : const Color(0xFF7C4DFF).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFEA79), Color(0xFFFF9800), Color(0xFFE65100)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isClaimed ? Icons.check_circle_rounded : Icons.card_giftcard_rounded,
              color: isClaimed ? const Color(0xFF00E676) : Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'DAY 7 • MEGA JACKPOT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2700),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Grand Weekly Reward',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isClaimed ? 'Claimed this cycle!' : 'Complete the 7-day cycle to claim!',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$coins',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isToday) {
      return megaCard
          .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
          .shimmer(delay: 400.ms, duration: 1400.ms)
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 1000.ms);
    }

    return megaCard.animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  /// Modern Bottom Claim Action Bar
  Widget _buildBottomActionBar(DailyRewardController controller, bool canClaim, int todayReward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF071426).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF194578),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: canClaim
          ? GestureDetector(
              onTap: controller.claimTodayReward,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFEA79),
                      Color(0xFFFF9800),
                      Color(0xFFE65100),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFF176),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    const BoxShadow(
                      color: Color(0xFFBF360C),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CLAIM TODAY\'S REWARD (+$todayReward COINS)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            )
              .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 900.ms)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E2544).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00E676),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S REWARD CLAIMED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Next reward unlocks tomorrow! 🔥',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
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
