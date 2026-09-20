
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
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
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundMid,
              AppColors.backgroundBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==========================================
              // TOP BAR
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1764B5),
                              Color(0xFF0B3D88),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF28D9FF),
                            width: 1.3,
                          ),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0xFF064DA5),
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Screen Title
                    const Text(
                      'SELECT LEVEL',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const Spacer(),

                    // Coins Pill
                    Obx(
                          () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1764B5),
                              Color(0xFF0B3D88),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF28D9FF),
                            width: 1.2,
                          ),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0xFF064DA5),
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${storage.coins.value}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // DIFFICULTY FILTER TABS
              // ==========================================
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: controller.difficultyTabs.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.selectedTab.value == index;

                      final label =
                      controller.difficultyTabs[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              controller.selectTab(index),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF26E0F5),
                                  Color(0xFF0A9AF0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                                  : const LinearGradient(
                                colors: [
                                  Color(0xFF1764B5),
                                  Color(0xFF0B3D88),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius:
                              BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF61F0FF)
                                    : const Color(0xFF248ACB),
                                width: 1.3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00D9FF,
                                  ).withOpacity(0.25),
                                  blurRadius: 8,
                                ),
                              ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? const Color(0xFF002244)
                                      : Colors.white,
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

              // ==========================================
              // LEVELS GRID
              // ==========================================
              Expanded(
                child: Obx(() {
                  final levelIds =
                      controller.filteredLevelIds;

                  final unlockedLevel =
                      storage.unlockedLevel.value;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    physics: const BouncingScrollPhysics(),

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),

                    itemCount: levelIds.length,

                    itemBuilder: (context, index) {
                      final lvlId = levelIds[index];

                      final isUnlocked =
                          lvlId <= unlockedLevel;

                      final stars =
                      storage.getStarsForLevel(lvlId);

                      final isCurrent =
                          lvlId == unlockedLevel;

                      return _buildLevelTile(
                        levelId: lvlId,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        stars: stars,
                        onTap: () =>
                            controller.onLevelTapped(lvlId),
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

  // ==========================================
  // LEVEL TILE
  // ==========================================
  Widget _buildLevelTile({
    required int levelId,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required VoidCallback onTap,
  }) {
    final Color borderColor = isCurrent
        ? const Color(0xFF5AF0FF)
        : isUnlocked
        ? const Color(0xFF248ACB)
        : const Color(0xFF244B76);

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? const LinearGradient(
            colors: [
              Color(0xFF1A67B8),
              Color(0xFF0B3C83),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
            colors: [
              Color(0xFF17365F),
              Color(0xFF0B2448),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.0 : 1.2,
          ),
          boxShadow: isCurrent
              ? [
            BoxShadow(
              color: const Color(0xFF00D9FF)
                  .withOpacity(0.35),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
              : [
            const BoxShadow(
              color: Color(0xFF062652),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              // Level Number
              Text(
                '$levelId',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: isCurrent
                      ? const Color(0xFF5AF0FF)
                      : Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              // Stars
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
                        : const Color(0xFF527093),
                  );
                }),
              ),
            ] else ...[
              // Locked Icon
              const Icon(
                Icons.lock_rounded,
                color: Color(0xFF527093),
                size: 23,
              ),

              const SizedBox(height: 5),

              // Locked Level Number
              Text(
                '$levelId',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF527093),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}