import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final bool isTutorial;

  const GameView({super.key, this.levelId, this.isTutorial = false});

  @override
  Widget build(BuildContext context) {
    final effectiveLevelId = levelId ?? StorageService.to.currentLevel.value;
    final controller = Get.put(GameController(
      initialLevelId: effectiveLevelId,
      isTutorial: isTutorial,
    ));
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

                if (isTutorial) _buildTutorialGuide(controller),
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
          // Tutorial is a guided flow, so it intentionally has no back button.
          if (isTutorial)
            const SizedBox(width: 48)
          else
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
                  isTutorial ? 'HOW TO PLAY' : 'LEVEL ${controller.levelId.value}',
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
              if (!isTutorial) ...[
                const SizedBox(width: 8),
                // Pause is available only in normal gameplay.
                IconButton(
                  icon: const Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 28),
                  onPressed: () => controller.openPauseMenu(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottlesGrid(GameController controller, String skinType) {
    final bottleCount = controller.bottles.length;

    if (isTutorial) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 48,
        children: List.generate(
          bottleCount,
          (index) => _buildBottleItem(controller, index, skinType),
        ),
      );
    }

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
    if (isTutorial) return const SizedBox(height: 88);
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

  Widget _buildTutorialGuide(GameController controller) {
    return Obx(() {
      final chooseTarget = controller.tutorialStep.value == 1;
      final message = chooseTarget
          ? 'Great! Now tap the bottle with 3 drops.'
          : 'Tap the bottle with 1 drop to pick it up.';
      return IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 24,
              right: 24,
              top: 108,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: AppTheme.glassBox(
                  color: AppColors.backgroundMid.withAlpha(235),
                  borderRadius: 18,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _TutorialFinger(
              key: ValueKey('tutorial-finger-${controller.tutorialStep.value}'),
              bottleKey: controller.getBottleKey(chooseTarget ? 1 : 0),
            ),
          ],
        ),
      );
    });
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

/// Keeps the tutorial hand centered on its target bottle, even on differently
/// sized devices. It also glides and pulses to make the next interaction clear.
class _TutorialFinger extends StatefulWidget {
  final GlobalKey bottleKey;

  const _TutorialFinger({super.key, required this.bottleKey});

  @override
  State<_TutorialFinger> createState() => _TutorialFingerState();
}

class _TutorialFingerState extends State<_TutorialFinger> {
  Offset? _bottleCenter;

  @override
  void initState() {
    super.initState();
    _measureBottleCenter();
  }

  void _measureBottleCenter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlayBox = context.findRenderObject() as RenderBox?;
      final bottleBox = widget.bottleKey.currentContext?.findRenderObject() as RenderBox?;
      if (overlayBox == null || bottleBox == null) return;

      final bottleCenterOnScreen = bottleBox.localToGlobal(
        bottleBox.size.center(Offset.zero),
      );
      setState(() {
        _bottleCenter = overlayBox.globalToLocal(bottleCenterOnScreen);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = _bottleCenter;
    if (center == null) return const SizedBox.shrink();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      left: center.dx - 28,
      top: center.dy - 28,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryCyan.withAlpha(190), width: 2),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.35, 1.35), duration: 900.ms)
                .fadeOut(begin: 0.85),
            const Icon(
              Icons.touch_app_rounded,
              size: 46,
              color: AppColors.primaryCyan,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: -7, end: 7, duration: 550.ms, curve: Curves.easeInOut)
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 550.ms),
          ],
        ),
      ),
    );
  }
}
