import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// StorageService manages persistent player data using SharedPreferences.
/// Designed with a clean interface so Hive or an alternative storage engine
/// can replace it seamlessly if desired.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  late SharedPreferences _prefs;

  // Keys
  static const String _keyCoins = 'asm_coins';
  static const String _keyUnlockedLevel = 'asm_unlocked_level';
  static const String _keyCurrentLevel = 'asm_current_level';
  static const String _keyLevelStars = 'asm_level_stars';
  static const String _keyCompletedCount = 'asm_completed_count';
  static const String _keyTutorialCompleted = 'asm_tutorial_completed';

  static const String _keyBottleSkins = 'asm_unlocked_bottle_skins';
  static const String _keyEquippedBottle = 'asm_equipped_bottle';
  static const String _keyBackgrounds = 'asm_unlocked_backgrounds';
  static const String _keyEquippedBackground = 'asm_equipped_background';

  static const String _keySound = 'asm_sound_enabled';
  static const String _keyMusic = 'asm_music_enabled';
  static const String _keyVibration = 'asm_vibration_enabled';

  static const String _keyDailyLastClaim = 'asm_daily_last_claim';
  static const String _keyDailyStreak = 'asm_daily_streak';

  // Reactive Observables for Real-time UI updates
  final RxInt coins = 100.obs;
  final RxInt unlockedLevel = 1.obs;
  final RxInt currentLevel = 1.obs;
  final RxMap<int, int> levelStars = <int, int>{}.obs;
  final RxInt completedCount = 0.obs;
  final RxBool tutorialCompleted = false.obs;

  final RxList<String> unlockedBottleSkins = <String>['glass'].obs;
  final RxString equippedBottleSkin = 'glass'.obs;
  final RxList<String> unlockedBackgrounds = <String>['ocean'].obs;
  final RxString equippedBackground = 'ocean'.obs;

  final RxBool soundEnabled = true.obs;
  final RxBool musicEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;

  final RxInt dailyStreak = 0.obs;
  final RxString lastDailyClaimDate = ''.obs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAll();
    return this;
  }

  void _loadAll() {
    coins.value = _prefs.getInt(_keyCoins) ?? 100;
    unlockedLevel.value = _prefs.getInt(_keyUnlockedLevel) ?? 1;
    currentLevel.value = _prefs.getInt(_keyCurrentLevel) ?? 1;
    completedCount.value = _prefs.getInt(_keyCompletedCount) ?? 0;
    tutorialCompleted.value = _prefs.getBool(_keyTutorialCompleted) ?? false;

    // Load stars map
    final starsRaw = _prefs.getString(_keyLevelStars);
    if (starsRaw != null && starsRaw.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(starsRaw);
        final parsed = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
        levelStars.assignAll(parsed);
      } catch (_) {
        levelStars.clear();
      }
    }

    // Load cosmetics
    final skinsList = _prefs.getStringList(_keyBottleSkins);
    if (skinsList != null && skinsList.isNotEmpty) {
      unlockedBottleSkins.assignAll(skinsList);
    } else {
      unlockedBottleSkins.assignAll(['glass']);
    }
    equippedBottleSkin.value = _prefs.getString(_keyEquippedBottle) ?? 'glass';

    final bgList = _prefs.getStringList(_keyBackgrounds);
    if (bgList != null && bgList.isNotEmpty) {
      unlockedBackgrounds.assignAll(bgList);
    } else {
      unlockedBackgrounds.assignAll(['ocean']);
    }
    equippedBackground.value = _prefs.getString(_keyEquippedBackground) ?? 'ocean';

    // Load audio & vibration settings
    soundEnabled.value = _prefs.getBool(_keySound) ?? true;
    musicEnabled.value = _prefs.getBool(_keyMusic) ?? true;
    vibrationEnabled.value = _prefs.getBool(_keyVibration) ?? true;

    // Load daily reward & streak
    dailyStreak.value = _prefs.getInt(_keyDailyStreak) ?? 0;
    lastDailyClaimDate.value = _prefs.getString(_keyDailyLastClaim) ?? '';
  }

  // --- Economy Methods ---

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    coins.value += amount;
    await _prefs.setInt(_keyCoins, coins.value);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins.value < amount) return false;
    coins.value -= amount;
    await _prefs.setInt(_keyCoins, coins.value);
    return true;
  }

  // --- Level Progress ---

  Future<void> completeLevel(int levelId, int stars) async {
    // Update stars (keep highest)
    final existingStars = levelStars[levelId] ?? 0;
    if (stars > existingStars) {
      levelStars[levelId] = stars;
      final encoded = jsonEncode(levelStars.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(_keyLevelStars, encoded);
    }

    // Increment completed count
    completedCount.value++;
    await _prefs.setInt(_keyCompletedCount, completedCount.value);

    // Unlock next level
    if (levelId >= unlockedLevel.value) {
      unlockedLevel.value = levelId + 1;
      await _prefs.setInt(_keyUnlockedLevel, unlockedLevel.value);
    }
  }

  Future<void> setCurrentLevel(int levelId) async {
    currentLevel.value = levelId;
    await _prefs.setInt(_keyCurrentLevel, currentLevel.value);
  }

  int getStarsForLevel(int levelId) {
    return levelStars[levelId] ?? 0;
  }

  bool isLevelUnlocked(int levelId) {
    return levelId <= unlockedLevel.value;
  }

  /// The interactive tutorial is only dismissed after the player completes it.
  Future<void> completeTutorial() async {
    tutorialCompleted.value = true;
    await _prefs.setBool(_keyTutorialCompleted, true);
  }

  // --- Cosmetics & Shop ---

  Future<bool> buyAndUnlockBottleSkin(BottleSkinType skin) async {
    if (unlockedBottleSkins.contains(skin.name)) {
      equippedBottleSkin.value = skin.name;
      await _prefs.setString(_keyEquippedBottle, skin.name);
      return true;
    }

    if (await spendCoins(skin.price)) {
      unlockedBottleSkins.add(skin.name);
      equippedBottleSkin.value = skin.name;
      await _prefs.setStringList(_keyBottleSkins, unlockedBottleSkins.toList());
      await _prefs.setString(_keyEquippedBottle, skin.name);
      return true;
    }
    return false;
  }

  Future<void> equipBottleSkin(String skinName) async {
    if (unlockedBottleSkins.contains(skinName)) {
      equippedBottleSkin.value = skinName;
      await _prefs.setString(_keyEquippedBottle, skinName);
    }
  }

  Future<bool> buyAndUnlockBackground(BackgroundThemeType bg) async {
    if (unlockedBackgrounds.contains(bg.name)) {
      equippedBackground.value = bg.name;
      await _prefs.setString(_keyEquippedBackground, bg.name);
      return true;
    }

    if (await spendCoins(bg.price)) {
      unlockedBackgrounds.add(bg.name);
      equippedBackground.value = bg.name;
      await _prefs.setStringList(_keyBackgrounds, unlockedBackgrounds.toList());
      await _prefs.setString(_keyEquippedBackground, bg.name);
      return true;
    }
    return false;
  }

  Future<void> equipBackground(String bgName) async {
    if (unlockedBackgrounds.contains(bgName)) {
      equippedBackground.value = bgName;
      await _prefs.setString(_keyEquippedBackground, bgName);
    }
  }

  // --- Settings ---

  Future<void> setSoundEnabled(bool enabled) async {
    soundEnabled.value = enabled;
    await _prefs.setBool(_keySound, enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled.value = enabled;
    await _prefs.setBool(_keyMusic, enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    vibrationEnabled.value = enabled;
    await _prefs.setBool(_keyVibration, enabled);
  }

  // --- Daily Reward & Streak System ---

  String get _todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get _yesterdayDateString {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  bool isDailyRewardClaimable() {
    final lastClaim = lastDailyClaimDate.value;
    final today = _todayDateString;
    return lastClaim != today;
  }

  Future<int> claimDailyReward() async {
    if (!isDailyRewardClaimable()) return 0;

    final today = _todayDateString;
    final yesterday = _yesterdayDateString;

    if (lastDailyClaimDate.value == yesterday) {
      dailyStreak.value += 1;
    } else {
      // Streak broken or brand new
      dailyStreak.value = 1;
    }

    // Determine current day in 7-day cycle (0 to 6)
    final cycleDay = (dailyStreak.value - 1) % 7;
    final rewardCoins = AppConstants.dailyRewards[cycleDay];

    await addCoins(rewardCoins);
    lastDailyClaimDate.value = today;
    await _prefs.setString(_keyDailyLastClaim, today);
    await _prefs.setInt(_keyDailyStreak, dailyStreak.value);

    return rewardCoins;
  }

  // --- Reset Progress ---

  Future<void> resetAll() async {
    await _prefs.clear();
    coins.value = 100;
    unlockedLevel.value = 1;
    currentLevel.value = 1;
    completedCount.value = 0;
    tutorialCompleted.value = false;
    levelStars.clear();
    unlockedBottleSkins.assignAll(['glass']);
    equippedBottleSkin.value = 'glass';
    unlockedBackgrounds.assignAll(['ocean']);
    equippedBackground.value = 'ocean';
    soundEnabled.value = true;
    musicEnabled.value = true;
    vibrationEnabled.value = true;
    dailyStreak.value = 0;
    lastDailyClaimDate.value = '';
  }
}
