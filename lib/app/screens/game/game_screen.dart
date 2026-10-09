import 'package:water_bottle_ais/exports.dart';

/// Main interactive puzzle screen with modern ambient stage gaming aesthetic
class GameScreen extends StatelessWidget {
  final int? levelId;
  final bool isTutorial;

  const GameScreen({super.key, this.levelId, this.isTutorial = false});

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
                _buildAmbientStageLighting(currentBg),

                Column(
                  children: [
                    _buildTopBar(context, controller, coins, currentLevel, difficultyText),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildBoardPedestal(currentBg),

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

                    _buildBottomToolbar(
                      controller,
                      moveHistoryCount: moveHistoryCount,
                      extraBottleDisabled: extraBottleDisabled,
                      hintCount: hintCount,
                    ),
                  ],
                ),

                PourStreamOverlay(
                  startPoint: controller.streamStart.value,
                  endPoint: controller.streamEnd.value,
                  colorId: controller.streamColor.value,
                  streamProgress: controller.streamProgress.value,
                ),

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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF113866), Color(0xFF092040)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF2885DE).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0072FF).withValues(alpha: 0.22),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTutorial ? 'TUTORIAL' : 'LEVEL $currentLevel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                if (!isTutorial) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    difficultyText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF80E5FF),
                    ),
                  ),
                ],
              ],
            ),
          ),

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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: controller.openPauseMenu,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2A52).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E60A8),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottlesGrid(GameController controller, String skinType) {
    final count = controller.bottles.length;
    int crossAxisCount = 4;
    if (count <= 6) {
      crossAxisCount = 3;
    } else if (count >= 12) {
      crossAxisCount = 5;
    }

    return Wrap(
      spacing: 14,
      runSpacing: 22,
      alignment: WrapAlignment.center,
      children: List.generate(count, (idx) {
        final bottle = controller.bottles[idx];
        final isSelected = controller.selectedBottleIndex.value == idx;

        return Builder(
          builder: (context) {
            return BottleWidget(
              bottle: bottle,
              index: idx,
              isSelected: isSelected,
              skinType: skinType,
              onTap: () {
                final box = context.findRenderObject() as RenderBox?;
                final position = box?.localToGlobal(Offset(box.size.width / 2, 20)) ?? Offset.zero;
                controller.onBottleTapped(idx, position);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildBottomToolbar(
    GameController controller, {
    required int moveHistoryCount,
    required bool extraBottleDisabled,
    required int hintCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF061426).withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1E5696).withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            badgeText: moveHistoryCount > 0 ? '$moveHistoryCount' : null,
            enabled: moveHistoryCount > 0,
            onTap: controller.undoMove,
          ),
          _buildToolButton(
            icon: Icons.lightbulb_rounded,
            label: 'Hint',
            badgeText: hintCount > 0 ? '$hintCount' : null,
            enabled: true,
            color: const Color(0xFFFFD700),
            onTap: controller.useHint,
          ),
          _buildToolButton(
            icon: Icons.add_circle_rounded,
            label: '+ Bottle',
            enabled: !extraBottleDisabled,
            color: const Color(0xFF00E676),
            onTap: controller.addExtraEmptyBottleWithAd,
          ),
          _buildToolButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            enabled: true,
            onTap: controller.restartLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    Color? color,
    String? badgeText,
  }) {
    final activeColor = color ?? const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2A52).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: activeColor.withValues(alpha: enabled ? 0.6 : 0.2),
                      width: 1.2,
                    ),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? activeColor : Colors.white38,
                    size: 24,
                  ),
                ),
                if (badgeText != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF002244),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialGuide(GameController controller) {
    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D284B).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF00E5FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFF002244),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Obx(() {
                final step = controller.tutorialStep.value;
                String text = 'Tap a bottle to select it, then tap another bottle to pour matching water!';
                if (step == 1) {
                  text = 'Great! Now tap a bottle with matching top color or an empty bottle to pour!';
                }
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                );
              }),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
