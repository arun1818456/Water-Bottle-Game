import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/leaderboard/leaderboard_controller.dart';

/// StorageService manages persistent player data using SharedPreferences.
/// Designed with a clean interface so Hive or an alternative storage engine
/// can replace it seamlessly if desired.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  late SharedPreferences _prefs;

  /// Optional listener triggered when important player progress changes
  VoidCallback? onDataChanged;

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

  static const String _keyUserId = 'asm_user_id';
  static const String _keyUserName = 'asm_user_name';
  static const String _keyUserPhotoUrl = 'asm_user_photo_url';
  static const String _keyUserAvatar = 'asm_user_avatar';
  static const String _keyUserEmail = 'asm_user_email';
  static const String _keyCountryFlag = 'asm_user_country_flag';
  static const String _keyLastRank = 'asm_last_leaderboard_rank';
  static const String _keyNotificationIndex = 'asm_notification_message_idx';
  static const String _keyGooglePromoShown = 'asm_google_promo_shown';
  static const String _keyLastSignedInUid = 'asm_last_signed_in_uid';
  static const String _keyCachedLeaderboard = 'asm_cached_cloud_leaderboard';

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
  final RxMusicEnabled musicEnabled = RxMusicEnabled(true);
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

    // Load audio, vibration & accessibility settings
    soundEnabled.value = _prefs.getBool(_keySound) ?? true;
    musicEnabled.value = _prefs.getBool(_keyMusic) ?? true;
    vibrationEnabled.value = _prefs.getBool(_keyVibration) ?? true;

    // Load daily reward & streak
    dailyStreak.value = _prefs.getInt(_keyDailyStreak) ?? 0;
    lastDailyClaimDate.value = _prefs.getString(_keyDailyLastClaim) ?? '';

    // Load user photo & email
    userPhotoUrl.value = _prefs.getString(_keyUserPhotoUrl) ?? '';
    userEmail.value = _prefs.getString(_keyUserEmail) ?? '';
    userCountryFlag.value = getOrCreateCountryFlag();
  }

  // --- User Profile & Identification ---

  final RxString userAvatarEmoji = '🎮'.obs;
  final RxString userPhotoUrl = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userCountryFlag = '🌍'.obs;

  /// Detects the user's country code from the device platform dispatcher
  /// and converts it to a country flag emoji (e.g., 'IN' -> '🇮🇳', 'US' -> '🇺🇸').
  String detectDeviceCountryFlag() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null && countryCode.length == 2) {
        final firstChar = String.fromCharCode(0x1F1E6 + (countryCode.codeUnitAt(0) - 65));
        final secondChar = String.fromCharCode(0x1F1E6 + (countryCode.codeUnitAt(1) - 65));
        return '$firstChar$secondChar';
      }
    } catch (e) {
      debugPrint('StorageService: detectDeviceCountryFlag error: $e');
    }
    return '🌍';
  }

  String getOrCreateCountryFlag() {
    String? flag = _prefs.getString(_keyCountryFlag);
    if (flag == null || flag.isEmpty || flag == '🇮🇳' && _prefs.getString(_keyCountryFlag) == null) {
      flag = detectDeviceCountryFlag();
      _prefs.setString(_keyCountryFlag, flag);
    }
    userCountryFlag.value = flag;
    return flag;
  }

  Future<void> setUserCountryFlag(String flag) async {
    if (flag.isEmpty || userCountryFlag.value == flag) return;
    userCountryFlag.value = flag;
    await _prefs.setString(_keyCountryFlag, flag);
    onDataChanged?.call();
  }

  int getLastLeaderboardRank() {
    return _prefs.getInt(_keyLastRank) ?? 0;
  }

  Future<void> setLastLeaderboardRank(int rank) async {
    await _prefs.setInt(_keyLastRank, rank);
  }

  int getNextNotificationIndex(int totalCount) {
    if (totalCount <= 0) return 0;
    final current = _prefs.getInt(_keyNotificationIndex) ?? 0;
    final next = (current + 1) % totalCount;
    _prefs.setInt(_keyNotificationIndex, next);
    return current % totalCount;
  }

  String getOrCreateUserId() {
    String? id = _prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) {
      id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _prefs.setString(_keyUserId, id);
    }
    return id;
  }

  String getOrCreateUserName() {
    String? name = _prefs.getString(_keyUserName);
    if (name == null || name.isEmpty) {
      final rand = (DateTime.now().millisecondsSinceEpoch % 8999) + 1000;
      name = 'Player_$rand';
      _prefs.setString(_keyUserName, name);
    }
    return name;
  }

  String getOrCreateUserAvatar() {
    String? emoji = _prefs.getString(_keyUserAvatar);
    if (emoji == null || emoji.isEmpty) {
      emoji = '🎮';
      _prefs.setString(_keyUserAvatar, emoji);
    }
    userAvatarEmoji.value = emoji;
    return emoji;
  }

  Future<void> setUserName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || _prefs.getString(_keyUserName) == trimmed) return;
    await _prefs.setString(_keyUserName, trimmed);
    onDataChanged?.call();
  }

  Future<void> setUserPhotoUrl(String url) async {
    if (userPhotoUrl.value == url) return;
    userPhotoUrl.value = url;
    await _prefs.setString(_keyUserPhotoUrl, url);
    onDataChanged?.call();
  }

  Future<void> setUserAvatar(String emoji) async {
    if (userAvatarEmoji.value == emoji) return;
    userAvatarEmoji.value = emoji;
    await _prefs.setString(_keyUserAvatar, emoji);
  }

  Future<void> setUserEmail(String email) async {
    if (userEmail.value == email) return;
    userEmail.value = email;
    await _prefs.setString(_keyUserEmail, email);
  }

  /// Backward compatible wrapper calling [mergeAndRestoreFromCloudMap]
  Future<void> restoreFromCloudMap(Map<String, dynamic> data) async {
    await mergeAndRestoreFromCloudMap(data);
  }

  /// Smartly merges cloud data with local progress without data loss.
  /// - If local is a fresh/unplayed session (level 1, 0 completions),
  ///   it fully restores the cloud account (coins, level, stars, cosmetics, streaks).
  /// - If local has progress, it keeps highest level, highest coins, union of skins,
  ///   and highest star ratings.
  Future<void> mergeAndRestoreFromCloudMap(Map<String, dynamic> data) async {
    final bool isLocalFresh = completedCount.value == 0 &&
        unlockedLevel.value <= 1 &&
        levelStars.isEmpty;

    // 1. Coins
    if (data.containsKey('coins') && data['coins'] is int) {
      final cloudCoins = data['coins'] as int;
      if (isLocalFresh || cloudCoins > coins.value) {
        coins.value = cloudCoins;
        await _prefs.setInt(_keyCoins, coins.value);
      }
    }

    // 2. Unlocked Level & Current Level
    if (data.containsKey('unlockedLevel') && data['unlockedLevel'] is int) {
      final cloudLevel = data['unlockedLevel'] as int;
      if (isLocalFresh || cloudLevel > unlockedLevel.value) {
        unlockedLevel.value = cloudLevel;
        currentLevel.value = cloudLevel;
        await _prefs.setInt(_keyUnlockedLevel, unlockedLevel.value);
        await _prefs.setInt(_keyCurrentLevel, currentLevel.value);
      }
    }

    // 3. Tutorial Completed: if level > 1 or completedCount > 0, tutorial is completed!
    if (unlockedLevel.value > 1 || completedCount.value > 0) {
      tutorialCompleted.value = true;
      await _prefs.setBool(_keyTutorialCompleted, true);
    }

    // 5. Level Stars: merge map preserving the highest star per level
    if (data.containsKey('levelStars') && data['levelStars'] is Map) {
      try {
        final Map rawMap = data['levelStars'] as Map;
        final Map<int, int> mergedStars = Map<int, int>.from(levelStars);
        rawMap.forEach((k, v) {
          final lvl = int.tryParse(k.toString());
          final star = v is int ? v : int.tryParse(v.toString());
          if (lvl != null && star != null) {
            final existing = mergedStars[lvl] ?? 0;
            if (isLocalFresh || star > existing) {
              mergedStars[lvl] = star;
            }
          }
        });
        levelStars.assignAll(mergedStars);
        await _prefs.setString(
          _keyLevelStars,
          jsonEncode(levelStars.map((k, v) => MapEntry(k.toString(), v))),
        );
      } catch (_) {}
    }

    // 6. Unlocked Bottle Skins: Set union
    if (data.containsKey('unlockedBottleSkins') && data['unlockedBottleSkins'] is List) {
      final cloudSkins = List<String>.from((data['unlockedBottleSkins'] as List).map((e) => e.toString()));
      final mergedSkins = Set<String>.from(unlockedBottleSkins)..addAll(cloudSkins);
      unlockedBottleSkins.assignAll(mergedSkins);
      await _prefs.setStringList(_keyBottleSkins, unlockedBottleSkins.toList());
    }

    // 7. Equipped Skin
    if (data.containsKey('equippedBottleSkin') && data['equippedBottleSkin'] is String) {
      final cloudEquipped = data['equippedBottleSkin'] as String;
      if (cloudEquipped.isNotEmpty && unlockedBottleSkins.contains(cloudEquipped)) {
        if (isLocalFresh || equippedBottleSkin.value == 'glass') {
          equippedBottleSkin.value = cloudEquipped;
          await _prefs.setString(_keyEquippedBottle, cloudEquipped);
        }
      }
    }

    // 8. Unlocked Backgrounds: Set union
    if (data.containsKey('unlockedBackgrounds') && data['unlockedBackgrounds'] is List) {
      final cloudBgs = List<String>.from((data['unlockedBackgrounds'] as List).map((e) => e.toString()));
      final mergedBgs = Set<String>.from(unlockedBackgrounds)..addAll(cloudBgs);
      unlockedBackgrounds.assignAll(mergedBgs);
      await _prefs.setStringList(_keyBackgrounds, unlockedBackgrounds.toList());
    }

    // 9. Equipped Background
    if (data.containsKey('equippedBackground') && data['equippedBackground'] is String) {
      final cloudBg = data['equippedBackground'] as String;
      if (cloudBg.isNotEmpty && unlockedBackgrounds.contains(cloudBg)) {
        if (isLocalFresh || equippedBackground.value == 'ocean') {
          equippedBackground.value = cloudBg;
          await _prefs.setString(_keyEquippedBackground, cloudBg);
        }
      }
    }

    // 10. User Name, PhotoUrl & CountryFlag (write directly without marking cloud dirty)
    if (data.containsKey('userName') && data['userName'] is String && (data['userName'] as String).isNotEmpty) {
      final cloudName = data['userName'] as String;
      final currentName = getOrCreateUserName();
      if ((isLocalFresh || currentName.startsWith('Player_')) && !cloudName.startsWith('Player_')) {
        await _prefs.setString(_keyUserName, cloudName);
      }
    }
    if (data.containsKey('photoUrl') && data['photoUrl'] is String && (data['photoUrl'] as String).isNotEmpty) {
      final cloudPhoto = data['photoUrl'] as String;
      if (userPhotoUrl.value != cloudPhoto) {
        userPhotoUrl.value = cloudPhoto;
        await _prefs.setString(_keyUserPhotoUrl, cloudPhoto);
      }
    }
    if (data.containsKey('countryFlag') && data['countryFlag'] is String && (data['countryFlag'] as String).isNotEmpty) {
      final cloudFlag = data['countryFlag'] as String;
      if (userCountryFlag.value != cloudFlag) {
        userCountryFlag.value = cloudFlag;
        await _prefs.setString(_keyCountryFlag, cloudFlag);
      }
    }
  }

  int get totalStarsCollected {
    int sum = levelStars.values.fold(0, (acc, s) => acc + s);
    if (sum == 0 && completedCount.value > 0) {
      return completedCount.value * 3;
    }
    return sum;
  }

  // --- Economy Methods ---

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    coins.value += amount;
    await _prefs.setInt(_keyCoins, coins.value);
    onDataChanged?.call();
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return true;
    if (coins.value < amount) return false;
    coins.value -= amount;
    await _prefs.setInt(_keyCoins, coins.value);
    onDataChanged?.call();
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

    onDataChanged?.call();
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
      onDataChanged?.call();
      return true;
    }

    if (await spendCoins(skin.price)) {
      unlockedBottleSkins.add(skin.name);
      equippedBottleSkin.value = skin.name;
      await _prefs.setStringList(_keyBottleSkins, unlockedBottleSkins.toList());
      await _prefs.setString(_keyEquippedBottle, skin.name);
      onDataChanged?.call();
      return true;
    }
    return false;
  }

  Future<void> equipBottleSkin(String skinName) async {
    if (unlockedBottleSkins.contains(skinName)) {
      equippedBottleSkin.value = skinName;
      await _prefs.setString(_keyEquippedBottle, skinName);
      onDataChanged?.call();
    }
  }

  Future<bool> buyAndUnlockBackground(BackgroundThemeType bg) async {
    if (unlockedBackgrounds.contains(bg.name)) {
      equippedBackground.value = bg.name;
      await _prefs.setString(_keyEquippedBackground, bg.name);
      onDataChanged?.call();
      return true;
    }

    if (await spendCoins(bg.price)) {
      unlockedBackgrounds.add(bg.name);
      equippedBackground.value = bg.name;
      await _prefs.setStringList(_keyBackgrounds, unlockedBackgrounds.toList());
      await _prefs.setString(_keyEquippedBackground, bg.name);
      onDataChanged?.call();
      return true;
    }
    return false;
  }

  Future<void> equipBackground(String bgName) async {
    if (unlockedBackgrounds.contains(bgName)) {
      equippedBackground.value = bgName;
      await _prefs.setString(_keyEquippedBackground, bgName);
      onDataChanged?.call();
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

  bool isStreakBroken() {
    final lastClaim = lastDailyClaimDate.value;
    if (lastClaim.isEmpty) return false;
    final today = _todayDateString;
    final yesterday = _yesterdayDateString;
    return lastClaim != today && lastClaim != yesterday;
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

  Future<void> resetDailyStreak() async {
    dailyStreak.value = 0;
    lastDailyClaimDate.value = '';
    await _prefs.setInt(_keyDailyStreak, 0);
    await _prefs.setString(_keyDailyLastClaim, '');
  }

  // --- Google Onboarding / Promo Dialog Flag ---

  bool hasGooglePromoBeenShown() {
    return _prefs.getBool(_keyGooglePromoShown) ?? false;
  }

  Future<void> setGooglePromoShown() async {
    await _prefs.setBool(_keyGooglePromoShown, true);
  }

  // --- Cached Real Firebase Leaderboard (Offline Support) ---

  /// Persists real Firebase leaderboard players in SharedPreferences so rank
  /// changes and offline leaderboard rendering work without hitting Firestore.
  Future<void> saveCachedLeaderboard(List<LeaderboardUser> users) async {
    if (users.isEmpty) return;
    final serialized = users
        .map((u) => {
              'name': u.name,
              'photoUrl': u.photoUrl,
              'avatarEmoji': u.avatarEmoji,
              'countryFlag': u.countryFlag,
              'stars': u.stars,
              'level': u.level,
              'isCurrentUser': u.isCurrentUser,
            })
        .toList();
    await _prefs.setString(_keyCachedLeaderboard, jsonEncode(serialized));
  }

  /// Builds a sorted leaderboard from the locally cached real Firebase users,
  /// updating the current user's live star/level count.
  /// Returns an empty list if no real Firebase leaderboard has been cached yet.
  List<LeaderboardUser> getCachedLeaderboard({
    int? overrideUserStars,
    int? overrideUserLevel,
  }) {
    final raw = _prefs.getString(_keyCachedLeaderboard);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) return [];

      final others = <LeaderboardUser>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final isMe = item['isCurrentUser'] == true;
        if (isMe) continue;
        others.add(
          LeaderboardUser(
            rank: 0,
            name: (item['name'] as String?) ?? 'Player',
            photoUrl: (item['photoUrl'] as String?) ?? '',
            avatarEmoji: (item['avatarEmoji'] as String?) ?? '🎮',
            countryFlag: (item['countryFlag'] as String?) ?? '🌍',
            stars: (item['stars'] as int?) ?? 0,
            level: (item['level'] as int?) ?? 1,
            isCurrentUser: false,
          ),
        );
      }

      if (others.isEmpty) return [];

      final myStars = overrideUserStars ?? totalStarsCollected;
      final myLevel = overrideUserLevel ?? unlockedLevel.value;
      final myName = getOrCreateUserName();
      final myPhoto = userPhotoUrl.value;
      final myAvatar = getOrCreateUserAvatar();
      final myFlag = getOrCreateCountryFlag();

      final entries = <LeaderboardUser>[
        ...others,
        LeaderboardUser(
          rank: 0,
          name: '$myName (You)',
          photoUrl: myPhoto,
          avatarEmoji: myAvatar,
          countryFlag: myFlag,
          stars: myStars,
          level: myLevel,
          isCurrentUser: true,
        ),
      ];

      entries.sort((a, b) {
        final cmp = b.stars.compareTo(a.stars);
        if (cmp != 0) return cmp;
        // On exact tie, keep existing real user ahead so player must pass (> stars) to overtake
        if (a.isCurrentUser != b.isCurrentUser) {
          return a.isCurrentUser ? 1 : -1;
        }
        return a.name.compareTo(b.name);
      });

      for (var i = 0; i < entries.length; i++) {
        final u = entries[i];
        entries[i] = LeaderboardUser(
          rank: i + 1,
          name: u.name,
          photoUrl: u.photoUrl,
          avatarEmoji: u.avatarEmoji,
          countryFlag: u.countryFlag,
          stars: u.stars,
          level: u.level,
          isCurrentUser: u.isCurrentUser,
        );
      }

      return entries;
    } catch (_) {
      return [];
    }
  }

  // --- Reset Progress ---

  String getLastSignedInUid() {
    return _prefs.getString(_keyLastSignedInUid) ?? '';
  }

  Future<void> setLastSignedInUid(String uid) async {
    if (uid.isEmpty) {
      await _prefs.remove(_keyLastSignedInUid);
    } else {
      await _prefs.setString(_keyLastSignedInUid, uid);
    }
  }

  /// Clears account-specific progress when signing out or switching Google accounts,
  /// while preserving local device settings (audio, vibration, tutorial, promo flag).
  Future<void> resetGameProgressForSignOut() async {
    await _prefs.remove(_keyCoins);
    await _prefs.remove(_keyUnlockedLevel);
    await _prefs.remove(_keyCurrentLevel);
    await _prefs.remove(_keyLevelStars);
    await _prefs.remove(_keyCompletedCount);
    await _prefs.remove(_keyBottleSkins);
    await _prefs.remove(_keyEquippedBottle);
    await _prefs.remove(_keyBackgrounds);
    await _prefs.remove(_keyEquippedBackground);
    await _prefs.remove(_keyDailyLastClaim);
    await _prefs.remove(_keyDailyStreak);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserPhotoUrl);
    await _prefs.remove(_keyUserAvatar);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyLastRank);
    await _prefs.remove(_keyLastSignedInUid);
    await _prefs.remove(_keyCachedLeaderboard);

    coins.value = 100;
    unlockedLevel.value = 1;
    currentLevel.value = 1;
    completedCount.value = 0;
    levelStars.clear();
    unlockedBottleSkins.assignAll(['glass']);
    equippedBottleSkin.value = 'glass';
    unlockedBackgrounds.assignAll(['ocean']);
    equippedBackground.value = 'ocean';
    dailyStreak.value = 0;
    lastDailyClaimDate.value = '';
    userEmail.value = '';
    userPhotoUrl.value = '';
    userAvatarEmoji.value = '🎮';
  }

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
    userEmail.value = '';
    userPhotoUrl.value = '';
    userAvatarEmoji.value = '🎮';
    userCountryFlag.value = detectDeviceCountryFlag();
  }
}

typedef RxMusicEnabled = RxBool;
