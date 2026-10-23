import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback_helper.dart';
import '../logic/level_manager.dart';
import '../logic/procedural_level_generator.dart';
import '../logic/water_sort_solver.dart';
import '../models/bottle.dart';
import '../models/game_move.dart';
import '../widgets/defeat_dialog.dart';
import '../widgets/pause_dialog.dart';
import '../widgets/victory_dialog.dart';

/// GameController drives liquid sort mechanics, animations, solver hints, and win/loss states
class GameController extends GetxController with GetTickerProviderStateMixin {
  final int initialLevelId;
  final bool isTutorial;

  GameController({this.initialLevelId = 1, this.isTutorial = false});

  // Reactive Game State
  final RxInt levelId = 1.obs;
  final RxString difficulty = 'Easy'.obs;
  final RxList<Bottle> bottles = <Bottle>[].obs;
  final RxnInt selectedBottleIndex = RxnInt();

  // Pour Animation States
  final RxBool isPouring = false.obs;
  final RxInt pouringSourceIndex = (-1).obs;
  final RxInt pouringTargetIndex = (-1).obs;
  final RxDouble pourTiltAngle = 0.0.obs;
  final Rx<Offset> pourTiltOffset = Offset.zero.obs;

  final Rx<Offset> streamStart = Offset.zero.obs;
  final Rx<Offset> streamEnd = Offset.zero.obs;
  final RxInt streamColor = 1.obs;
  final RxDouble streamProgress = 0.0.obs;
  final RxInt pouringAmount = 0.obs;

  // History & Metrics
  final List<GameMove> moveHistory = [];
  final RxInt moveCount = 0.obs;
  final RxInt undoUsedCount = 0.obs;
  final RxInt hintUsedCount = 0.obs;
  final RxInt extraBottlesAdded = 0.obs;
  bool get extraBottleDisabled => extraBottlesAdded.value >= AppConstants.maxExtraBottles;
  bool get addedExtraBottle => extraBottleDisabled;

  // Hints & Overlays
  final RxnInt hintSourceIndex = RxnInt();
  final RxnInt hintTargetIndex = RxnInt();
  final RxBool isGameWon = false.obs;
  final RxBool showCelebration = false.obs;
  final RxBool showDifficultySplash = false.obs;
  final RxBool isColorblindMode = false.obs;

  void toggleColorblindMode() {
    isColorblindMode.value = !isColorblindMode.value;
  }

  // 0 = choose the filled bottle, 1 = choose the empty bottle.
  final RxInt tutorialStep = 0.obs;

  // Key for stack overlay box to compute pixel-perfect relative pour coordinates
  final GlobalKey gameStackKey = GlobalKey();

  // Keys for bottle render boxes to calculate precise pour coordinates
  final Map<int, GlobalKey> bottleKeys = {};

  Offset _pourTargetOffset = Offset.zero;

  late LevelData _originalLevelData;
  late final AnimationController _pourAnimationController;

  @override
  void onInit() {
    super.onInit();
    levelId.value = initialLevelId;

    _pourAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    loadLevel(levelId.value);
  }

  @override
  void onClose() {
    _pourAnimationController.dispose();
    super.onClose();
  }

  GlobalKey getBottleKey(int index) {
    if (!bottleKeys.containsKey(index)) {
      bottleKeys[index] = GlobalKey();
    }
    return bottleKeys[index]!;
  }

  Future<void> loadLevel(int id) async {
    levelId.value = id;
    selectedBottleIndex.value = null;
    isPouring.value = false;
    pouringAmount.value = 0;
    isGameWon.value = false;
    showCelebration.value = false;
    showDifficultySplash.value = false;
    hintSourceIndex.value = null;
    hintTargetIndex.value = null;
    moveHistory.clear();
    moveCount.value = 0;
    undoUsedCount.value = 0;
    hintUsedCount.value = 0;
    extraBottlesAdded.value = 0;
    tutorialStep.value = 0;

    AdsService.to.preloadRewardedAd();

    if (isTutorial) {
      difficulty.value = 'Tutorial';
      // This is a self-contained demonstration, not the real first level:
      // move the single top layer into the bottle that already has three.
      bottles.assignAll([
        Bottle(layers: [1]),
        Bottle(layers: [1, 1, 1]),
      ]);
      return;
    }

    // Load handcrafted or procedural level
    _originalLevelData = await LevelManager.loadLevel(id);
    difficulty.value = _originalLevelData.difficulty;

    if (difficulty.value == 'Hard' || difficulty.value == 'Expert' || difficulty.value == 'Very Hard') {
      showDifficultySplash.value = true;
      Future.delayed(const Duration(milliseconds: 1800), () {
        showDifficultySplash.value = false;
      });
    }

    // Convert to bottle models
    final loadedBottles = <Bottle>[];
    for (var i = 0; i < _originalLevelData.bottles.length; i++) {
      final layers = _originalLevelData.bottles[i];
      final hidden = (_originalLevelData.hiddenLayers != null && i < _originalLevelData.hiddenLayers!.length)
          ? Set<int>.from(_originalLevelData.hiddenLayers![i])
          : <int>{};
      final bottle = Bottle(layers: List<int>.from(layers), hiddenIndices: hidden);
      bottle.checkAndRevealTop();
      loadedBottles.add(bottle);
    }

    bottles.assignAll(loadedBottles);
    StorageService.to.setCurrentLevel(id);
  }

  void restartLevel() {
    AudioService.to.playButtonClick();
    loadLevel(levelId.value);
  }

  void onBottleTapped(int index) {
    if (isPouring.value || isGameWon.value) return;

    // Clear active hint indicators on user action
    hintSourceIndex.value = null;
    hintTargetIndex.value = null;

    final tappedBottle = bottles[index];

    // Case 1: No bottle currently selected
    if (selectedBottleIndex.value == null) {
      if (tappedBottle.isEmpty) {
        HapticFeedbackHelper.selectionClick();
        return;
      }
      // If bottle is already full and completed, no need to pour out of it
      if (!isTutorial && tappedBottle.isCompleted && tappedBottle.isFull) {
        HapticFeedbackHelper.selectionClick();
        return;
      }

      selectedBottleIndex.value = index;
      if (isTutorial && index == 0) {
        tutorialStep.value = 1;
      }
      AudioService.to.playBottleTapSound();
      HapticFeedbackHelper.lightImpact();
      return;
    }

    // Case 2: A bottle was already selected
    final selectedIdx = selectedBottleIndex.value!;

    if (selectedIdx == index) {
      // Tap same bottle again to deselect
      selectedBottleIndex.value = null;
      AudioService.to.playBottleTapSound();
      HapticFeedbackHelper.selectionClick();
      return;
    }

    final sourceBottle = bottles[selectedIdx];
    final targetBottle = bottles[index];

    // Check if pour is valid
    if (sourceBottle.canPourInto(targetBottle)) {
      _executePour(selectedIdx, index);
    } else {
      // If tapped bottle is non-empty and not complete, switch selection to it
      if (targetBottle.isNotEmpty && !(targetBottle.isCompleted && targetBottle.isFull)) {
        selectedBottleIndex.value = index;
        AudioService.to.playBottleTapSound();
        HapticFeedbackHelper.lightImpact();
      } else {
        // Invalid destination
        selectedBottleIndex.value = null;
        HapticFeedbackHelper.mediumImpact();
      }
    }
  }

  Future<void> _executePour(int fromIdx, int toIdx) async {
    isPouring.value = true;
    pouringSourceIndex.value = fromIdx;
    pouringTargetIndex.value = toIdx;

    final source = bottles[fromIdx];
    final target = bottles[toIdx];
    final colorToPour = source.topColor!;
    final amountToPour = source.calculatePourAmount(target);

    final sourceHiddenBefore = Set<int>.from(source.hiddenIndices);
    final targetHiddenBefore = Set<int>.from(target.hiddenIndices);

    // Calculate source and target coordinates for stream and pour direction
    final isTargetLeft = _calculateStreamCoordinates(fromIdx, toIdx);
    streamColor.value = colorToPour;
    pouringAmount.value = amountToPour;

    // Determine tilt direction based on physical position of target relative to source
    final tiltDirection = isTargetLeft ? -1.0 : 1.0;
    final targetAngle = tiltDirection * 1.1; // ~63 degrees tilt

    AudioService.to.playPourSound();
    HapticFeedbackHelper.mediumImpact();

    // Animate pour stream
    _pourAnimationController.reset();

    void animationListener() {
      final t = _pourAnimationController.value;

      // Sequence:
      // 0.0 - 0.2: Move and tilt
      // 0.2 - 0.8: Pour (hold position)
      // 0.8 - 1.0: Move back and untilt
      double phase = 0.0;
      if (t <= 0.2) {
        phase = t / 0.2;
      } else if (t <= 0.8) {
        phase = 1.0;
      } else {
        phase = 1.0 - ((t - 0.8) / 0.2);
      }

      final curvedPhase = Curves.easeInOut.transform(phase);

      pourTiltAngle.value = targetAngle * curvedPhase;
      pourTiltOffset.value = _pourTargetOffset * curvedPhase;

      // Stream runs from 0.2 to 0.8
      streamProgress.value = ((t - 0.2) / 0.6).clamp(0.0, 1.0);
    }
    _pourAnimationController.addListener(animationListener);

    await _pourAnimationController.forward();
    _pourAnimationController.removeListener(animationListener);

    // Commit liquid transfer to bottle models
    source.pourInto(target);
    final sourceRevealed = source.checkAndRevealTop();
    final targetRevealed = target.checkAndRevealTop();
    if (sourceRevealed || targetRevealed) {
      AudioService.to.playBottleTapSound();
      HapticFeedbackHelper.mediumImpact();
    }

    bottles.refresh();

    // Record move in history
    moveHistory.add(GameMove(
      fromIndex: fromIdx,
      toIndex: toIdx,
      color: colorToPour,
      amount: amountToPour,
      sourceHiddenBefore: sourceHiddenBefore,
      targetHiddenBefore: targetHiddenBefore,
    ));
    moveCount.value++;

    // Reset pour visual state
    isPouring.value = false;
    selectedBottleIndex.value = null;
    pouringSourceIndex.value = -1;
    pouringTargetIndex.value = -1;
    pouringAmount.value = 0;
    pourTiltAngle.value = 0.0;
    pourTiltOffset.value = Offset.zero;
    streamProgress.value = 0.0;

    // Check Victory or Defeat
    _checkGameStateAfterMove();
  }

  bool _calculateStreamCoordinates(int fromIdx, int toIdx) {
    try {
      final stackContext = gameStackKey.currentContext;
      final fromContext = bottleKeys[fromIdx]?.currentContext;
      final toContext = bottleKeys[toIdx]?.currentContext;

      if (stackContext != null && fromContext != null && toContext != null) {
        final stackBox = stackContext.findRenderObject() as RenderBox?;
        final fromBox = fromContext.findRenderObject() as RenderBox?;
        final toBox = toContext.findRenderObject() as RenderBox?;

        if (stackBox != null && fromBox != null && toBox != null) {
          final fromPos = stackBox.globalToLocal(fromBox.localToGlobal(Offset.zero));
          final toPos = stackBox.globalToLocal(toBox.localToGlobal(Offset.zero));
          final bottleWidth = toBox.size.width; // 58.0

          // Determine if target bottle is physically to the left of source bottle on screen
          final isTargetLeft = toPos.dx < fromPos.dx;

          // Target mouth top-center coordinate
          final targetMouthX = toPos.dx + bottleWidth / 2;
          final targetMouthY = toPos.dy;

          // Spout target position: pouring bottle hovers HIGHER UP in the air above target bottle (28px above rim)
          final spoutTargetX = targetMouthX + (isTargetLeft ? 14.0 : -14.0);
          final spoutTargetY = targetMouthY - 28.0;

          // Source bottle pivot (top center before translation)
          final sourcePivotX = fromPos.dx + bottleWidth / 2;
          final sourcePivotY = fromPos.dy;

          // When tilted by ~57 deg (1.0 rad), pouring lip offsets relative to pivot:
          final lipOffsetDx = isTargetLeft ? -6.5 : 6.5;
          final lipOffsetDy = 12.5;

          final offsetDx = spoutTargetX - sourcePivotX - lipOffsetDx;
          final offsetDy = spoutTargetY - sourcePivotY - lipOffsetDy;

          _pourTargetOffset = Offset(offsetDx, offsetDy);

          // Stream starts directly at the higher pouring lip (spout) of tilted bottle
          streamStart.value = Offset(spoutTargetX, spoutTargetY);

          // Stream ends inside target bottle opening
          streamEnd.value = Offset(targetMouthX, targetMouthY + 15.0);
          return isTargetLeft;
        }
      }
    } catch (_) {}

    final isTargetLeft = toIdx < fromIdx;
    _pourTargetOffset = Offset(isTargetLeft ? -40.0 : 40.0, -28.0);
    streamStart.value = const Offset(150, 200);
    streamEnd.value = const Offset(150, 230);
    return isTargetLeft;
  }

  void _checkGameStateAfterMove() {
    if (WaterSortSolver.isSolved(bottles)) {
      _handleVictory();
    } else if (!WaterSortSolver.hasAnyValidMove(bottles)) {
      _handleDefeat();
    }
  }

  Future<void> _handleVictory() async {
    isGameWon.value = true;
    showCelebration.value = true;
    AudioService.to.playWinSound();
    HapticFeedbackHelper.winVibration();

    // Star calculation:
    // 3 Stars: 0 undos and 0 hints used
    // 2 Stars: <= 2 undos or 1 hint
    // 1 Star: 3+ assists
    int stars = 3;
    if (undoUsedCount.value > 2 || hintUsedCount.value > 1) {
      stars = 1;
    } else if (undoUsedCount.value > 0 || hintUsedCount.value > 0) {
      stars = 2;
    }

    final starBonus = (stars == 3)
        ? AppConstants.coinsFor3Stars
        : (stars == 2 ? AppConstants.coinsFor2Stars : AppConstants.coinsFor1Star);

    final totalEarned = AppConstants.coinsPerLevelClear + starBonus;

    int actualCoinsEarned = 0;

    if (isTutorial) {
      await StorageService.to.completeTutorial();
    } else {
      final existingStars = StorageService.to.getStarsForLevel(levelId.value);
      final isFirstCompletion = existingStars == 0;

      if (isFirstCompletion) {
        // First completion: full rewards (base clear coins + star bonus)
        actualCoinsEarned = totalEarned;
      } else if (stars > existingStars) {
        // Replayed level with improved star score: award star upgrade difference
        final oldStarBonus = (existingStars == 2)
            ? AppConstants.coinsFor2Stars
            : (existingStars == 1 ? AppConstants.coinsFor1Star : 0);
        actualCoinsEarned = max(0, starBonus - oldStarBonus);
      } else {
        // Replayed already completed level with no star improvement: 0 coins
        actualCoinsEarned = 0;
      }

      await StorageService.to.completeLevel(levelId.value, stars);
    }

    // Show Interstitial ad if eligible (every 4 levels)
    await Future.delayed(const Duration(milliseconds: 900));

    AdsService.to.showInterstitialIfEligible(onComplete: () {
      Get.dialog(
        VictoryDialog(
          levelId: levelId.value,
          stars: stars,
          baseCoins: actualCoinsEarned,
          onNextLevel: () => nextLevel(),
          onRestart: () => restartLevel(),
          onHome: () => isTutorial ? Get.offAllNamed('/home') : Get.back(),
          showNextLevel: !isTutorial,
          showReplay: !isTutorial,
          homeLabel: isTutorial ? 'Home' : 'Levels',
          title: isTutorial ? 'WELL DONE!' : 'VICTORY!',
          subtitle: isTutorial ? 'Tutorial Complete' : 'Level ${levelId.value} Cleared',
        ),
        barrierDismissible: false,
      );
    });
  }

  void _handleDefeat() {
    Future.delayed(const Duration(milliseconds: 450), () {
      Get.dialog(
        DefeatDialog(
          onUndo: () => undoMove(),
          onRestart: () => restartLevel(),
          onAddBottle: () => addExtraEmptyBottleWithAd(),
          extraBottleDisabled: extraBottleDisabled,
        ),
        barrierDismissible: false,
      );
    });
  }

  void undoMove() {
    if (isPouring.value || moveHistory.isEmpty) return;

    AudioService.to.playButtonClick();
    HapticFeedbackHelper.lightImpact();

    final lastMove = moveHistory.removeLast();
    lastMove.undo(bottles);
    bottles.refresh();

    undoUsedCount.value++;
    selectedBottleIndex.value = null;
    hintSourceIndex.value = null;
    hintTargetIndex.value = null;
  }

  void requestHint() {
    if (isPouring.value || isGameWon.value) return;

    if (hintUsedCount.value < 2) {
      // Free hint
      _provideHint();
    } else {
      // Ad required
      AudioService.to.playButtonClick();
      AdsService.to.showRewardedAd(
        onUserEarnedReward: (reward) {
          _provideHint();
        },
      );
    }
  }

  void _provideHint() {
    AudioService.to.playButtonClick();
    HapticFeedbackHelper.lightImpact();

    final hint = WaterSortSolver.findNextHint(bottles);
    if (hint != null) {
      hintSourceIndex.value = hint.fromIndex;
      hintTargetIndex.value = hint.toIndex;
      hintUsedCount.value++;
      selectedBottleIndex.value = hint.fromIndex;
    } else {
      Get.snackbar(
        'No Solution Found',
        'Consider using Undo or Restart.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void addExtraEmptyBottleWithAd() {
    if (extraBottleDisabled) return;

    AdsService.to.showRewardedAd(
      onUserEarnedReward: (reward) {
        addExtraEmptyBottle();
      },
    );
  }

  void addExtraEmptyBottle() {
    if (extraBottleDisabled) return;

    extraBottlesAdded.value++;
    bottles.add(Bottle());
    bottles.refresh();
    AudioService.to.playButtonClick();
    HapticFeedbackHelper.mediumImpact();
  }

  void nextLevel() {
    loadLevel(levelId.value + 1);
  }

  void openPauseMenu() {
    AudioService.to.playButtonClick();
    Get.dialog(
      PauseDialog(
        onResume: () {},
        onRestart: () => restartLevel(),
        onHome: () => Get.back(),
      ),
    );
  }
}
