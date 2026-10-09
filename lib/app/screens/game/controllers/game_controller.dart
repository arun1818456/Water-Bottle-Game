import 'dart:async';
import 'package:water_bottle_ais/exports.dart';

/// GameController manages the full reactive state for liquid sorting puzzle gameplay
class GameController extends GetxController {
  final int initialLevelId;
  final bool isTutorial;

  GameController({
    required this.initialLevelId,
    this.isTutorial = false,
  });

  // State Observables
  final RxInt levelId = 1.obs;
  final RxList<Bottle> bottles = <Bottle>[].obs;
  final RxnInt selectedBottleIndex = RxnInt();
  final RxInt moveCount = 0.obs;
  final RxInt hintUsedCount = 0.obs;
  final RxInt undoUsedCount = 0.obs;
  final RxBool isLevelCompleted = false.obs;
  final RxBool isLevelDefeated = false.obs;
  final RxBool addedExtraBottle = false.obs;
  final RxString difficulty = 'Medium'.obs;

  // Visual Effects State
  final RxBool showCelebration = false.obs;
  final RxMap<int, bool> completedBottles = <int, bool>{}.obs;

  // Pour Animation Stream Overlay State
  final Rxn<Offset> streamStart = Rxn<Offset>();
  final Rxn<Offset> streamEnd = Rxn<Offset>();
  final RxnInt streamColor = RxnInt();
  final RxDouble streamProgress = 0.0.obs;
  bool isPouring = false;

  // Undo History Stack
  final List<GameMove> moveHistory = [];

  // Tutorial Flow State
  final RxInt tutorialStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadLevel(initialLevelId);
  }

  /// Loads a level by ID or falls back to procedural generator
  Future<void> loadLevel(int targetLevel) async {
    levelId.value = targetLevel;
    StorageService.to.setCurrentLevel(targetLevel);

    selectedBottleIndex.value = null;
    moveCount.value = 0;
    hintUsedCount.value = 0;
    undoUsedCount.value = 0;
    isLevelCompleted.value = false;
    isLevelDefeated.value = false;
    addedExtraBottle.value = false;
    showCelebration.value = false;
    completedBottles.clear();
    moveHistory.clear();
    streamProgress.value = 0.0;
    streamStart.value = null;
    streamEnd.value = null;
    isPouring = false;
    tutorialStep.value = 0;

    if (isTutorial) {
      difficulty.value = 'Tutorial';
      _loadTutorialBottles();
      return;
    }

    try {
      final loadedBottles = await LevelManager.loadLevel(targetLevel);
      if (loadedBottles.isNotEmpty) {
        bottles.assignAll(loadedBottles);
        _updateDifficultyTag(targetLevel);
        _checkInitialCompletedBottles();
        return;
      }
    } catch (e) {
      debugPrint('GameController: Level file error: $e');
    }

    // Fallback to procedural generator
    final generated = ProceduralLevelGenerator.generateLevel(
      levelId: targetLevel,
      bottleCapacity: AppConstants.maxBottleCapacity,
    );
    final generatedBottles = generated.bottles
        .map((b) => Bottle(capacity: AppConstants.maxBottleCapacity, layers: List<int>.from(b)))
        .toList();
    bottles.assignAll(generatedBottles);
    _updateDifficultyTag(targetLevel);
    _checkInitialCompletedBottles();
  }

  void _loadTutorialBottles() {
    // A simple 2-move tutorial setup
    bottles.assignAll([
      Bottle(layers: [1, 1, 2, 2]),
      Bottle(layers: [2, 2, 1, 1]),
      Bottle(layers: []),
    ]);
  }

  void _updateDifficultyTag(int lvl) {
    if (lvl <= 20) {
      difficulty.value = 'Easy';
    } else if (lvl <= 50) {
      difficulty.value = 'Medium';
    } else if (lvl <= 80) {
      difficulty.value = 'Hard';
    } else if (lvl <= 100) {
      difficulty.value = 'Expert';
    } else {
      difficulty.value = 'Master';
    }
  }

  void _checkInitialCompletedBottles() {
    for (var i = 0; i < bottles.length; i++) {
      final b = bottles[i];
      if (b.isFull && b.isPure) {
        completedBottles[i] = true;
      }
    }
  }

  /// Handles user tapping a bottle
  void onBottleTapped(int index, Offset globalPosition) {
    if (isPouring || isLevelCompleted.value || isLevelDefeated.value) return;

    final selected = selectedBottleIndex.value;

    if (selected == null) {
      // Select source bottle if not empty and not already completed
      if (bottles[index].isNotEmpty) {
        if (completedBottles[index] == true) {
          AudioService.to.playButtonClick();
          HapticFeedbackHelper.selectionClick();
          return;
        }
        selectedBottleIndex.value = index;
        AudioService.to.playBottleTapSound();
        HapticFeedbackHelper.lightImpact();

        if (isTutorial && tutorialStep.value == 0) {
          tutorialStep.value = 1;
        }
      }
    } else if (selected == index) {
      // Deselect
      selectedBottleIndex.value = null;
      AudioService.to.playButtonClick();
      HapticFeedbackHelper.selectionClick();
    } else {
      // Attempt pour from selected into index
      final source = bottles[selected];
      final target = bottles[index];

      if (source.canPourInto(target)) {
        _executePour(selected, index, globalPosition);
      } else {
        // Invalid pour: select the tapped bottle if not empty, otherwise deselect
        if (target.isNotEmpty && completedBottles[index] != true) {
          selectedBottleIndex.value = index;
          AudioService.to.playBottleTapSound();
          HapticFeedbackHelper.lightImpact();
        } else {
          selectedBottleIndex.value = null;
          AudioService.to.playButtonClick();
          HapticFeedbackHelper.selectionClick();
        }
      }
    }
  }

  /// Executes animated liquid pour with audio, haptics, and move history
  void _executePour(int fromIdx, int toIndex, Offset endPos) async {
    isPouring = true;
    final source = bottles[fromIdx];
    final target = bottles[toIndex];

    final colorToPour = source.topColor!;
    final amountPoured = source.calculatePourAmount(target);

    // Save move to history before mutating
    moveHistory.add(GameMove(
      fromIndex: fromIdx,
      toIndex: toIndex,
      color: colorToPour,
      amount: amountPoured,
    ));

    // Audio & Haptic feedback
    AudioService.to.playPourSound();
    HapticFeedbackHelper.mediumImpact();

    // Configure stream overlay animation
    streamColor.value = colorToPour;
    streamEnd.value = endPos;
    streamStart.value = endPos.translate(0, -180);

    // Animate stream
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      streamProgress.value = i / 10.0;
    }

    // Mutate state
    source.pourInto(target);
    bottles.refresh();
    moveCount.value++;
    selectedBottleIndex.value = null;

    // Reset stream
    streamProgress.value = 0.0;
    streamStart.value = null;
    streamEnd.value = null;
    isPouring = false;

    // Check if target bottle completed
    if (target.isFull && target.isPure) {
      completedBottles[toIndex] = true;
      AudioService.to.playWinSound();
      HapticFeedbackHelper.heavyImpact();
    }

    // Check level win condition
    if (_checkWinCondition()) {
      _handleVictory();
    } else if (_checkDefeatCondition()) {
      _handleDefeat();
    }
  }

  /// Undo last pour move
  void undoMove() {
    if (moveHistory.isEmpty || isPouring || isLevelCompleted.value) return;

    final lastMove = moveHistory.removeLast();
    lastMove.undo(bottles);
    undoUsedCount.value++;
    bottles.refresh();

    // Re-check completed states
    completedBottles.remove(lastMove.toIndex);
    if (bottles[lastMove.fromIndex].isFull && bottles[lastMove.fromIndex].isPure) {
      completedBottles[lastMove.fromIndex] = true;
    }

    selectedBottleIndex.value = null;
    AudioService.to.playButtonClick();
    HapticFeedbackHelper.lightImpact();
  }

  /// Calculates a solver hint using BFS
  void useHint() {
    if (isPouring || isLevelCompleted.value) return;

    final solution = WaterSortSolver.solve(bottles);
    if (solution != null && solution.isNotEmpty) {
      final nextMove = solution.first;
      hintUsedCount.value++;

      // Auto-select source bottle of hint
      selectedBottleIndex.value = nextMove.fromIndex;
      AudioService.to.playWinSound();
      HapticFeedbackHelper.mediumImpact();

      Get.snackbar(
        'Hint Suggested!',
        'Pour bottle ${nextMove.fromIndex + 1} into bottle ${nextMove.toIndex + 1}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.backgroundMid.withValues(alpha: 0.9),
        colorText: AppColors.primaryCyan,
        icon: const Icon(Icons.lightbulb_rounded, color: AppColors.primaryCyan),
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'No Solution Path',
        'Try using Undo or adding an extra empty bottle!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.backgroundMid.withValues(alpha: 0.9),
        colorText: Colors.orangeAccent,
        icon: const Icon(Icons.warning_rounded, color: Colors.orangeAccent),
      );
    }
  }

  /// Restarts current level
  void restartLevel() {
    AudioService.to.playButtonClick();
    loadLevel(levelId.value);
  }

  bool _checkWinCondition() {
    return bottles.every((b) => b.isCompleted);
  }

  bool _checkDefeatCondition() {
    if (isLevelCompleted.value) return false;
    // Defeat occurs if no valid pours exist between any pair of bottles
    return !WaterSortSolver.hasAnyValidMove(bottles);
  }

  void _handleVictory() async {
    isLevelCompleted.value = true;
    showCelebration.value = true;
    AudioService.to.playWinSound();
    HapticFeedbackHelper.winVibration();

    // Calculate stars and coin earnings
    int stars = 3;
    if (undoUsedCount.value > 2 || hintUsedCount.value > 1) {
      stars = 1;
    } else if (undoUsedCount.value > 0 || hintUsedCount.value > 0) {
      stars = 2;
    }

    final baseCoins = AppConstants.coinsPerLevelClear;
    final starBonus = stars == 3
        ? AppConstants.coinsFor3Stars
        : (stars == 2 ? AppConstants.coinsFor2Stars : AppConstants.coinsFor1Star);
    final totalEarned = baseCoins + starBonus;

    if (isTutorial) {
      await StorageService.to.completeTutorial();
    } else {
      await StorageService.to.completeLevel(levelId.value, stars);
      await StorageService.to.addCoins(totalEarned);
    }

    await Future.delayed(const Duration(milliseconds: 700));
    Get.dialog(
      VictoryDialog(
        levelId: levelId.value,
        stars: stars,
        baseCoins: totalEarned,
        onNextLevel: () => nextLevel(),
        onRestart: () => restartLevel(),
        onHome: () => isTutorial ? Get.offAllNamed(AppRoutes.homeScreen) : Get.back(),
        showNextLevel: !isTutorial,
        showReplay: !isTutorial,
        homeLabel: isTutorial ? 'Home' : 'Levels',
        title: isTutorial ? 'WELL DONE!' : 'VICTORY!',
        subtitle: isTutorial ? 'Tutorial Complete' : 'Level ${levelId.value} Cleared',
      ),
      barrierDismissible: false,
    );
  }

  void _handleDefeat() {
    Future.delayed(const Duration(milliseconds: 450), () {
      Get.dialog(
        DefeatDialog(
          onUndo: () => undoMove(),
          onRestart: () => restartLevel(),
          onAddBottle: () => addExtraEmptyBottleWithAd(),
        ),
        barrierDismissible: false,
      );
    });
  }

  void addExtraEmptyBottleWithAd() {
    addExtraEmptyBottle();
  }

  void addExtraEmptyBottle() {
    if (addedExtraBottle.value) return;

    addedExtraBottle.value = true;
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
