import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_images.dart';
import 'level_controller.dart';

/// Modern High-Aesthetic Level Select Screen
class LevelSelectView extends StatelessWidget {
  const LevelSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LevelController());

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with dark luxury glass overlay
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
              final coins = controller.storage.coins.value;
              final unlockedLevel = controller.storage.unlockedLevel.value;
              final selectedTab = controller.selectedTab.value;
              final levelIds = controller.filteredLevelIds;

              // Calculate total stars collected
              int totalStars = 0;
              for (int i = 1; i <= AppConstants.totalHandcraftedLevels; i++) {
                totalStars += controller.storage.getStarsForLevel(i);
              }

              return Column(
                children: [
                  // Top Header Bar
                  _buildTopBar(coins),

                  // Progress Stats Banner
                  _buildProgressBanner(unlockedLevel, totalStars),

                  const SizedBox(height: 10),

                  // Difficulty Filter Carousel
                  _buildDifficultyTabs(controller, selectedTab),

                  const SizedBox(height: 12),

                  // Levels Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: levelIds.length,
                      itemBuilder: (context, index) {
                        final lvlId = levelIds[index];
                        final isUnlocked = lvlId <= unlockedLevel;
                        final isCurrent = lvlId == unlockedLevel;
                        final stars = controller.storage.getStarsForLevel(lvlId);

                        return _buildLevelTile(
                          levelId: lvlId,
                          isUnlocked: isUnlocked,
                          isCurrent: isCurrent,
                          stars: stars,
                          onTap: () => controller.onLevelTapped(lvlId),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Top Bar with Glass Back Button, Title, and Coins Counter
  Widget _buildTopBar(int coins) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  'SELECT LEVEL',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                '120 Handcrafted Challenges',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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

  /// Progress Summary Banner
  Widget _buildProgressBanner(int unlockedLevel, int totalStars) {
    final maxLevel = AppConstants.totalHandcraftedLevels;
    final maxStars = maxLevel * 3;
    final progress = (unlockedLevel / maxLevel).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F315E), Color(0xFF081F3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF268AFF).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0072FF).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Level progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level $unlockedLevel / $maxLevel',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 18),

            // Total Stars Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStars',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    '/$maxStars',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  /// Difficulty Tabs Carousel
  Widget _buildDifficultyTabs(LevelController controller, int selectedTab) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.difficultyTabs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedTab == index;
          final label = controller.difficultyTabs[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.selectTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF0D2B52).withValues(alpha: 0.8),
                            const Color(0xFF081D38).withValues(alpha: 0.8),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF80E5FF)
                        : const Color(0xFF1E5696).withValues(alpha: 0.4),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Individual Level Tile
  Widget _buildLevelTile({
    required int levelId,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required VoidCallback onTap,
  }) {
    Widget tile = GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrent
              ? const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF), Color(0xFF0549A5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : (isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFF174C88), Color(0xFF0B2D54)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF0C1E36), Color(0xFF06101E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFF80E5FF)
                : (isUnlocked
                    ? const Color(0xFF2885DE).withValues(alpha: 0.6)
                    : Colors.white10),
            width: isCurrent ? 2.2 : 1.2,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Color(0xFF042B60),
                    offset: Offset(0, 4),
                  ),
                ]
              : (isUnlocked
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              // Level Number
              Text(
                '$levelId',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isCurrent ? Colors.white : Colors.white,
                  shadows: isCurrent
                      ? [
                          const Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),

              const SizedBox(height: 4),

              // 3 Stars Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (starIdx) {
                  final hasStar = starIdx < stars;
                  return Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: hasStar
                        ? const Color(0xFFFFD700)
                        : (isCurrent
                            ? Colors.white38
                            : const Color(0xFF29568A)),
                  );
                }),
              ),
            ] else ...[
              // Locked State
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF3B6496),
                  size: 18,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$levelId',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B6496),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isCurrent) {
      return tile
          .animate(onPlay: Get.testMode ? null : (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.04, 1.04), duration: 1000.ms);
    }

    return tile;
  }
}