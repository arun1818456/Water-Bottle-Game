import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import 'controllers/game_controller.dart';
import 'widgets/bottle_widget.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/pour_stream_overlay.dart';

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
        final difficultyText = controller.difficulty.value;
        final moveHistoryCount = controller.moveHistory.length;
        final extraBottleDisabled = controller.extraBottleDisabled;
        final hintCount = controller.hintUsedCount.value;

        return Container(
          decoration: _buildBackgroundDecoration(currentBg),
          child: SafeArea(
            bottom: false,
            child: Stack(
              key: controller.gameStackKey,
              children: [
                // Ambient stage light aura behind bottles
                _buildAmbientStageLighting(currentBg),

                Column(
                  children: [
                    // Top App Bar with all Circular Action & Navigation Buttons
                    _buildTopBar(
                      context,
                      controller,
                      moveHistoryCount: moveHistoryCount,
                      extraBottleDisabled: extraBottleDisabled,
                      hintCount: hintCount,
                    ),

                    const SizedBox(height: 8),

                    // Middle Bottles Board with floating glass stage platform (positioned higher & fully responsive)
                    Expanded(
                      child: Align(
                        alignment: const Alignment(0.0, -0.35),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glowing frosted glass pedestal platform beneath the bottles
                                  _buildBoardPedestal(currentBg),

                                  // Bottles Grid
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    child: _buildBottlesGrid(controller, currentSkin),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Banner Ad at absolute bottom for all levels
                    _buildBannerAdContainer(),
                  ],
                ),

                // Active Pour Stream Layer
                PourStreamOverlay(
                  startPoint: controller.streamStart.value,
                  endPoint: controller.streamEnd.value,
                  colorId: controller.streamColor.value,
                  streamProgress: controller.streamProgress.value,
                ),

                // Active Pouring Bottle Overlay (ALWAYS ON TOP OF ALL BOTTLES)
                if (controller.isPouring.value && controller.pouringSourceIndex.value >= 0)
                  _buildPouringBottleOverlay(controller, currentSkin),

                // Victory Confetti Layer
                if (controller.showCelebration.value)
                  const CelebrationOverlay(),

                // Difficulty Splash Animation Layer
                if (controller.showDifficultySplash.value)
                  _buildDifficultySplash(difficultyText),

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

  /// Modern Top Header Bar containing all Circular Action & Navigation Buttons
  Widget _buildTopBar(
    BuildContext context,
    GameController controller, {
    required int moveHistoryCount,
    required bool extraBottleDisabled,
    required int hintCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause Menu Button (Left side)
          if (isTutorial)
            const SizedBox(width: 40)
          else
            _buildCircularIconButton(
              icon: Icons.pause_rounded,
              iconColor: Colors.white,
              onTap: () {
                AudioService.to.playButtonClick();
                HapticFeedbackHelper.selectionClick();
                controller.openPauseMenu();
              },
            ),

          // Action Circular Buttons (+ Bottle, Restart, Undo, Hint)
          if (!isTutorial)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Extra Bottle (+ Bottle)
                    _buildCircularIconButton(
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      badge: extraBottleDisabled ? null : 'Ad',
                      badgeColor: const Color(0xFF00E5FF),
                      disabled: extraBottleDisabled,
                      onTap: () {
                        AudioService.to.playButtonClick();
                        HapticFeedbackHelper.selectionClick();
                        controller.addExtraEmptyBottleWithAd();
                      },
                    ),

                    // Restart
                    _buildCircularIconButton(
                      icon: Icons.refresh_rounded,
                      iconColor: const Color(0xFFFFB300),
                      onTap: () {
                        AudioService.to.playButtonClick();
                        HapticFeedbackHelper.selectionClick();
                        controller.restartLevel();
                      },
                    ),

                    // Undo
                    _buildCircularIconButton(
                      icon: Icons.undo_rounded,
                      iconColor: const Color(0xFF7C4DFF),
                      badge: moveHistoryCount > 0 ? '$moveHistoryCount' : null,
                      badgeColor: const Color(0xFF7C4DFF),
                      disabled: moveHistoryCount == 0,
                      onTap: () {
                        AudioService.to.playButtonClick();
                        HapticFeedbackHelper.selectionClick();
                        controller.undoMove();
                      },
                    ),

                    // Hint
                    _buildCircularIconButton(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: const Color(0xFF00E676),
                      badge: hintCount < 3 ? 'Free' : 'Ad',
                      badgeColor: hintCount < 3 ? const Color(0xFF00E676) : const Color(0xFFFFB300),
                      onTap: () {
                        AudioService.to.playButtonClick();
                        HapticFeedbackHelper.selectionClick();
                        controller.requestHint();
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Right side: Eyes Toggle Button
          if (isTutorial)
            const SizedBox(width: 40)
          else
            _buildCircularIconButton(
              icon: controller.isColorblindMode.value
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              iconColor: controller.isColorblindMode.value
                  ? const Color(0xFF00E5FF)
                  : Colors.white70,
              isActive: controller.isColorblindMode.value,
              onTap: () {
                AudioService.to.playButtonClick();
                HapticFeedbackHelper.selectionClick();
                controller.toggleColorblindMode();
              },
            ),
        ],
      ),
    );
  }

  /// Universal Circular Glass Icon Button with optional badge (softer & faded style)
  Widget _buildCircularIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
    Color badgeColor = const Color(0xFF00E5FF),
    bool disabled = false,
    bool isActive = false,
    double size = 40,
    double iconSize = 20,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: disabled
                  ? Colors.white.withValues(alpha: 0.05)
                  : isActive
                      ? iconColor.withValues(alpha: 0.28)
                      : const Color(0xFF0E2A52).withValues(alpha: 0.68),
              shape: BoxShape.circle,
              border: Border.all(
                color: disabled
                    ? Colors.white12
                    : isActive
                        ? iconColor.withValues(alpha: 0.85)
                        : iconColor.withValues(alpha: 0.42),
                width: 1.3,
              ),
              boxShadow: !disabled
                  ? [
                      BoxShadow(
                        color: iconColor.withValues(alpha: isActive ? 0.25 : 0.12),
                        blurRadius: 7,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: disabled ? Colors.white.withValues(alpha: 0.22) : iconColor,
              size: iconSize,
            ),
          ),
          if (badge != null && !disabled)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF001830),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Banner Ad container shown at absolute bottom for all levels
  Widget _buildBannerAdContainer() {
    // Ensure game banner ad is loaded
    AdsService.to.loadGameBanner();

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: AdsService.to.getGameBannerWidget(),
      ),
    );
  }

  List<int> _getRowLayout(int count) {
    if (count <= 0) return [];
    switch (count) {
      case 1: return [1];
      case 2: return [2];
      case 3: return [3];
      case 4: return [2, 2];
      case 5: return [2, 3];
      case 6: return [3, 3];
      case 7: return [3, 4];
      case 8: return [4, 4];
      case 9: return [3, 3, 3];
      case 10: return [3, 4, 3];
      case 11: return [4, 3, 4];
      case 12: return [4, 4, 4];
      case 13: return [4, 3, 3, 3];
      case 14: return [4, 4, 3, 3];
      case 15: return [4, 4, 4, 3];
      case 16: return [4, 4, 4, 4];
      default:
        int rows = (count / 4).ceil();
        if (rows <= 0) return [];
        int base = count ~/ rows;
        int remainder = count % rows;
        return List.generate(rows, (i) => base + (i < remainder ? 1 : 0));
    }
  }

  /// Responsive Bottle Grid based on custom counts
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

    final rowSizes = _getRowLayout(bottleCount);
    
    int currentIndex = 0;
    List<Widget> rowWidgets = [];

    for (int i = 0; i < rowSizes.length; i++) {
      final size = rowSizes[i];
      
      rowWidgets.add(
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 20,
          children: List.generate(size, (idx) {
            final bottleIndex = currentIndex + idx;
            return _buildBottleItem(controller, bottleIndex, skinType);
          }),
        ),
      );
      
      currentIndex += size;
      
      // Add spacing between rows, except for the last row
      if (i < rowSizes.length - 1) {
        rowWidgets.add(const SizedBox(height: 28));
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowWidgets,
    );
  }

  /// Bottle Item with full physics/animation parameters preserved
  Widget _buildBottleItem(GameController controller, int index, String skinType) {
    final bottle = controller.bottles[index];
    final isSelected = controller.selectedBottleIndex.value == index;
    final isHintSource = controller.hintSourceIndex.value == index;
    final isHintTarget = controller.hintTargetIndex.value == index;
    final isPouringSource = controller.pouringSourceIndex.value == index;
    final isPouringTarget = controller.pouringTargetIndex.value == index;

    if (isPouringSource) {
      // Hide source bottle in grid during pour because it is painted
      // in front via _buildPouringBottleOverlay to guarantee Z-index!
      return Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: BottleWidget(
          key: controller.getBottleKey(index),
          bottle: bottle,
          index: index,
          isSelected: false,
          skinType: skinType,
          isColorblindMode: controller.isColorblindMode.value,
          onTap: () {},
        ),
      );
    }

    final fillAmount = isPouringTarget
        ? controller.streamProgress.value * controller.pouringAmount.value
        : 0.0;
    final fillColor = isPouringTarget ? controller.streamColor.value : null;

    return BottleWidget(
      key: controller.getBottleKey(index),
      bottle: bottle,
      index: index,
      isSelected: isSelected,
      isHintSource: isHintSource,
      isHintTarget: isHintTarget,
      skinType: skinType,
      fillAmount: fillAmount,
      fillColor: fillColor,
      isColorblindMode: controller.isColorblindMode.value,
      onTap: () => controller.onBottleTapped(index),
    );
  }

  /// Renders the pouring bottle in a top-level Stack overlay to guarantee
  /// it is always drawn in front of the target bottle and all other grid bottles.
  Widget _buildPouringBottleOverlay(GameController controller, String skinType) {
    final fromIdx = controller.pouringSourceIndex.value;
    if (fromIdx < 0) return const SizedBox.shrink();

    final bottleKey = controller.getBottleKey(fromIdx);
    final context = bottleKey.currentContext;
    final stackContext = controller.gameStackKey.currentContext;
    if (context == null || stackContext == null) return const SizedBox.shrink();

    final renderBox = context.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null) return const SizedBox.shrink();

    final globalPos = renderBox.localToGlobal(Offset.zero);
    final localPos = stackBox.globalToLocal(globalPos);

    final bottle = controller.bottles[fromIdx];
    final drainAmount = controller.streamProgress.value * controller.pouringAmount.value;

    return Positioned(
      left: localPos.dx,
      top: localPos.dy,
      width: renderBox.size.width,
      height: renderBox.size.height,
      child: IgnorePointer(
        child: BottleWidget(
          bottle: bottle,
          index: fromIdx,
          isSelected: false,
          skinType: skinType,
          tiltAngle: controller.pourTiltAngle.value,
          tiltOffset: controller.pourTiltOffset.value,
          drainAmount: drainAmount,
          isColorblindMode: controller.isColorblindMode.value,
          onTap: () {},
        ),
      ),
    );
  }



  /// Tutorial Guidance View
  Widget _buildTutorialGuide(GameController controller) {
    return Obx(() {
      // Hide hand finger icon and guidance overlay during pour animation
      if (controller.isPouring.value) {
        return const SizedBox.shrink();
      }

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

/// Big center-screen animated splash overlay for Hard/Expert levels
Widget _buildDifficultySplash(String difficultyText) {
  Color glowColor = difficultyText == 'Expert' || difficultyText == 'Very Hard' 
      ? Colors.redAccent 
      : Colors.orangeAccent;

  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
        border: Border.all(color: glowColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: glowColor,
            size: 48,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 400.ms),
          const SizedBox(height: 12),
          Text(
            difficultyText.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(color: glowColor, blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be Careful!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms)
        .then(delay: 800.ms) // Holds for a moment
        .fadeOut(duration: 500.ms)
        .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 500.ms),
  );
}
