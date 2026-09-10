import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'level_controller.dart';

/// Level Select Screen displaying all 120 handcrafted levels
class LevelSelectView extends StatelessWidget {
  const LevelSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LevelController());
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
                      'SELECT LEVEL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Coins Pill
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: AppTheme.glassBox(borderRadius: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${storage.coins.value}',
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

              // Difficulty Filter Tabs
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.difficultyTabs.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected = controller.selectedTab.value == index;
                      final label = controller.difficultyTabs[index];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => controller.selectTab(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryCyan
                                  : AppColors.glassFill,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryCyan
                                    : AppColors.glassBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF002244)
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 120 Levels Grid
              Expanded(
                child: Obx(() {
                  final levelIds = controller.filteredLevelIds;
                  final unlockedLevel = storage.unlockedLevel.value;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: levelIds.length,
                    itemBuilder: (context, index) {
                      final lvlId = levelIds[index];
                      final isUnlocked = lvlId <= unlockedLevel;
                      final stars = storage.getStarsForLevel(lvlId);
                      final isCurrent = lvlId == unlockedLevel;

                      return _buildLevelTile(
                        levelId: lvlId,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        stars: stars,
                        onTap: () => controller.onLevelTapped(lvlId),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required int levelId,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primaryCyan.withAlpha(50)
              : (isUnlocked ? AppColors.glassFillHeavy : Colors.white.withAlpha(10)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent
                ? AppColors.primaryCyan
                : (isUnlocked ? AppColors.glassBorder : Colors.white12),
            width: isCurrent ? 2.0 : 1.2,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: AppColors.primaryCyan.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                '$levelId',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isCurrent ? AppColors.primaryCyan : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIdx) {
                  final hasStar = starIdx < stars;
                  return Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: hasStar ? const Color(0xFFFFD700) : Colors.white24,
                  );
                }),
              ),
            ] else ...[
              const Icon(
                Icons.lock_rounded,
                color: Colors.white24,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '$levelId',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
