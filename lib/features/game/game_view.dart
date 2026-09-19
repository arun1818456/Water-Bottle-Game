import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import 'controllers/game_controller.dart';
import 'widgets/bottle_widget.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/pour_stream_overlay.dart';

/// Main interactive puzzle screen
class GameView extends StatelessWidget {
  final int? levelId;

  const GameView({super.key, this.levelId});

  @override
  Widget build(BuildContext context) {
    final effectiveLevelId = levelId ?? StorageService.to.currentLevel.value;
    final controller = Get.put(GameController(initialLevelId: effectiveLevelId));
    final storage = StorageService.to;

    return Scaffold(
      body: Obx(() {
        final currentSkin = storage.equippedBottleSkin.value;
        final currentBg = storage.equippedBackground.value;

        return Container(
          decoration: _buildBackgroundDecoration(currentBg),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top App Bar
                    _buildTopBar(context, controller, storage),

                    const SizedBox(height: 12),

                    // Middle Bottles Board
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _buildBottlesGrid(controller, currentSkin),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Control Bar
                    _buildBottomToolbar(controller),
                  ],
                ),

                // Active Pour Stream Layer
                Obx(() => PourStreamOverlay(
                      startPoint: controller.streamStart.value,
                      endPoint: controller.streamEnd.value,
                      colorId: controller.streamColor.value,
                      streamProgress: controller.streamProgress.value,
                    )),

                // Victory Confetti Layer
                Obx(() {
                  if (controller.showCelebration.value) {
                    return const CelebrationOverlay();
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  BoxDecoration _buildBackgroundDecoration(String bgType) {
    switch (bgType) {
      case 'sunset':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1B4E), Color(0xFF511D4D), Color(0xFF9E2A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'space':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0C10), Color(0xFF1F2833), Color(0xFF110726)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'forest':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'ocean':
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundMid, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
    }
  }

  Widget _buildTopBar(BuildContext context, GameController controller, StorageService storage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
            onPressed: () => Get.back(),
          ),

          // Level badge with difficulty
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: AppTheme.glassBox(
              color: AppColors.glassFillHeavy,
              borderRadius: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL ${controller.levelId.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.primaryCyan,
                  ),
                ),
                Text(
                  controller.difficulty.value.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Right side: Coin pill & Pause
          Row(
            children: [
              // Coins
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.glassBox(borderRadius: 16),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '${storage.coins.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Pause
              IconButton(
                icon: const Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 28),
                onPressed: () => controller.openPauseMenu(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottlesGrid(GameController controller, String skinType) {
    final bottleCount = controller.bottles.length;

    // Split bottles into 2 balanced rows
    final mid = (bottleCount / 4).ceil();
    final topRowBottles = controller.bottles.sublist(0, mid);
    final bottomRowBottles = controller.bottles.sublist(mid);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 20,
          children: List.generate(topRowBottles.length, (idx) {
            return _buildBottleItem(controller, idx, skinType);
          }),
        ),

        const SizedBox(height: 28),

        // Bottom Row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 20,
          children: List.generate(bottomRowBottles.length, (idx) {
            final actualIdx = mid + idx;
            return _buildBottleItem(controller, actualIdx, skinType);
          }),
        ),
      ],
    );
  }

  Widget _buildBottleItem(GameController controller, int index, String skinType) {
    final bottle = controller.bottles[index];
    final isSelected = controller.selectedBottleIndex.value == index;
    final isHintSource = controller.hintSourceIndex.value == index;
    final isHintTarget = controller.hintTargetIndex.value == index;
    final isPouringSource = controller.pouringSourceIndex.value == index;

    return BottleWidget(
      key: controller.getBottleKey(index),
      bottle: bottle,
      index: index,
      isSelected: isSelected,
      isHintSource: isHintSource,
      isHintTarget: isHintTarget,
      skinType: skinType,
      tiltAngle: isPouringSource ? controller.pourTiltAngle.value : 0.0,
      tiltOffset: isPouringSource ? controller.pourTiltOffset.value : Offset.zero,
      onTap: () => controller.onBottleTapped(index),
    );
  }

  Widget _buildBottomToolbar(GameController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: AppTheme.glassBox(
        color: AppColors.backgroundMid.withAlpha(200),
        borderRadius: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Extra Bottle Powerup
          _buildToolButton(
            icon: Icons.add_circle_outline_rounded,
            label: '+ Bottle',
            badge: 'Ad',
            onTap: () => controller.addExtraEmptyBottleWithAd(),
            disabled: controller.addedExtraBottle.value,
          ),

          // Restart
          _buildToolButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            onTap: () => controller.restartLevel(),
          ),

          // Undo
          _buildToolButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            badge: controller.moveHistory.isNotEmpty ? '${controller.moveHistory.length}' : null,
            onTap: () => controller.undoMove(),
            disabled: controller.moveHistory.isEmpty,
          ),

          // Hint
          Obx(() => _buildToolButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Hint',
                badge: controller.hintUsedCount.value < 3 ? 'Free' : 'Ad',
                onTap: () => controller.requestHint(),
              )),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    final color = disabled ? Colors.white24 : Colors.white;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002244),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
