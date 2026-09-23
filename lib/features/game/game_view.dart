import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import 'controllers/game_controller.dart';
import 'widgets/bottle_widget.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/pour_stream_overlay.dart';

/// Main interactive puzzle screen with modern ambient stage gaming aesthetic
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
        final coins = storage.coins.value;
        final currentLevel = controller.levelId.value;
        final difficultyText = controller.difficulty.value;
        final moveHistoryCount = controller.moveHistory.length;
        final extraBottleDisabled = controller.addedExtraBottle.value;
        final hintCount = controller.hintUsedCount.value;

        return Container(
          decoration: _buildBackgroundDecoration(currentBg),
          child: SafeArea(
            child: Stack(
              children: [
                // Ambient stage light aura behind bottles
                _buildAmbientStageLighting(currentBg),

                Column(
                  children: [
                    // Top App Bar
                    _buildTopBar(context, controller, coins, currentLevel, difficultyText),

                    const SizedBox(height: 8),

                    // Middle Bottles Board with floating glass stage platform
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing frosted glass pedestal platform beneath the bottles
                                _buildBoardPedestal(currentBg),

                                // Bottles Grid
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                                  child: _buildBottlesGrid(controller, currentSkin),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Control Toolbar
                    _buildBottomToolbar(
                      controller,
                      moveHistoryCount: moveHistoryCount,
                      extraBottleDisabled: extraBottleDisabled,
                      hintCount: hintCount,
                    ),
                  ],
                ),

                // Active Pour Stream Layer
                PourStreamOverlay(
                  startPoint: controller.streamStart.value,
                  endPoint: controller.streamEnd.value,
                  colorId: controller.streamColor.value,
                  streamProgress: controller.streamProgress.value,
                ),

                // Victory Confetti Layer
                if (controller.showCelebration.value)
                  const CelebrationOverlay(),

                if (isTutorial)
                  _buildTutorialGuide(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Ambient stage lighting aura centered on the game board
  Widget _buildAmbientStageLighting(String bgType) {
    Color glowColor;
    switch (bgType) {
      case 'sunset':
        glowColor = const Color(0xFFFF5252);
        break;
      case 'space':
        glowColor = const Color(0xFF7C4DFF);
        break;
      case 'forest':
        glowColor = const Color(0xFF00E676);
        break;
      case 'ocean':
      default:
        glowColor = const Color(0xFF00E5FF);
        break;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 340,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor.withValues(alpha: 0.14),
                  glowColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Glowing frosted glass pedestal platform under bottles
  Widget _buildBoardPedestal(String bgType) {
    Color rimColor;
    switch (bgType) {
      case 'sunset':
        rimColor = const Color(0xFFFF7043);
        break;
      case 'space':
        rimColor = const Color(0xFF9575CD);
        break;
      case 'forest':
        rimColor = const Color(0xFF4DB6AC);
        break;
      case 'ocean':
      default:
        rimColor = const Color(0xFF00E5FF);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF051122).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: rimColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: rimColor.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
    );
  }

  /// Builds ambient multi-layered clean atmospheric background
  BoxDecoration _buildBackgroundDecoration(String bgType) {
    switch (bgType) {
      case 'sunset':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1C0824),
              Color(0xFF2E0D2C),
              Color(0xFF44122D),
              Color(0xFF1A0518),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'space':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF04060E),
              Color(0xFF0B0E24),
              Color(0xFF151034),
              Color(0xFF03040A),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'forest':
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF041210),
              Color(0xFF092420),
              Color(0xFF0D3630),
              Color(0xFF030C0A),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case 'ocean':
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050E1B),
              Color(0xFF081B34),
              Color(0xFF0B264A),
              Color(0xFF040A14),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
    }
  }

  /// Modern Top Header Bar with Glass Capsule Level Display
  Widget _buildTopBar(
    BuildContext context,
    GameController controller,
    int coins,
    int currentLevel,
    String difficultyText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (isTutorial)
            const SizedBox(width: 42)
          else
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

          // Central Level Badge Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14457F), Color(0xFF0A2952)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF80E5FF),
                      Color(0xFFFFFFFF),
                      Color(0xFFFFD54F),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    isTutorial ? 'TUTORIAL' : 'LEVEL $currentLevel',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficultyText.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF80D8FF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right side: Coins pill & Pause button
          Row(
            children: [
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
                      size: 16,
                    ),
                    const SizedBox(width: 4),
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
              if (!isTutorial) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.openPauseMenu(),
                  child: Container(
                    width: 40,
                    height: 40,
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
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Responsive 2-Row Bottle Grid
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

  /// Bottle Item with full physics/animation parameters preserved
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

  /// Modern Floating Glass Bottom Toolbar
  Widget _buildBottomToolbar(
    GameController controller, {
    required int moveHistoryCount,
    required bool extraBottleDisabled,
    required int hintCount,
  }) {
    if (isTutorial) return const SizedBox(height: 88);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF081C38).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF1E5898).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Extra Bottle Powerup
          _buildToolButton(
            icon: Icons.add_circle_outline_rounded,
            iconColor: const Color(0xFF00E5FF),
            label: '+ Bottle',
            badge: 'Ad',
            badgeColor: const Color(0xFF00E5FF),
            onTap: () => controller.addExtraEmptyBottleWithAd(),
            disabled: extraBottleDisabled,
          ),

          // Restart
          _buildToolButton(
            icon: Icons.refresh_rounded,
            iconColor: const Color(0xFFFFB300),
            label: 'Restart',
            onTap: () => controller.restartLevel(),
          ),

          // Undo
          _buildToolButton(
            icon: Icons.undo_rounded,
            iconColor: const Color(0xFF7C4DFF),
            label: 'Undo',
            badge: moveHistoryCount > 0 ? '$moveHistoryCount' : null,
            badgeColor: const Color(0xFF7C4DFF),
            onTap: () => controller.undoMove(),
            disabled: moveHistoryCount == 0,
          ),

          // Hint
          _buildToolButton(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFF00E676),
            label: 'Hint',
            badge: hintCount < 3 ? 'Free' : 'Ad',
            badgeColor: hintCount < 3 ? const Color(0xFF00E676) : const Color(0xFFFFB300),
            onTap: () => controller.requestHint(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// Modern Interactive Tool Button
  Widget _buildToolButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? badge,
    Color badgeColor = const Color(0xFF00E5FF),
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: disabled
                        ? Colors.white.withValues(alpha: 0.04)
                        : iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: disabled
                          ? Colors.white12
                          : iconColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: !disabled
                        ? [
                            BoxShadow(
                              color: iconColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: disabled ? Colors.white24 : iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: disabled ? Colors.white24 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF002244),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Tutorial Guidance View
  Widget _buildTutorialGuide(GameController controller) {
    return Obx(() {
      final chooseTarget = controller.tutorialStep.value == 1;
      final message = chooseTarget
          ? 'Great! Now tap the bottle with matching color.'
          : 'Tap the bottle with water to select and pour.';

      return IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 24,
              right: 24,
              top: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF133662), Color(0xFF0A2240)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
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
                border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.75),
                  width: 2,
                ),
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
