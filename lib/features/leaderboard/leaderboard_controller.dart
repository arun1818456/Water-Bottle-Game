import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final String avatarEmoji;
  final String countryFlag;
  final int stars;
  final int level;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.avatarEmoji,
    required this.countryFlag,
    required this.stars,
    required this.level,
    this.isCurrentUser = false,
  });
}

class LeaderboardController extends GetxController {
  final storage = StorageService.to;

  final RxList<LeaderboardUser> leaderboardUsers = <LeaderboardUser>[].obs;
  final RxInt currentUserRank = 12.obs;
  final RxInt userTotalStars = 0.obs;
  final RxBool isLoading = false.obs;

  final RxBool isFirebaseActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    isLoading.value = true;
    userTotalStars.value = storage.totalStarsCollected;

    final firebaseAvailable = Get.isRegistered<FirebaseService>() && FirebaseService.to.isInitialized;
    isFirebaseActive.value = firebaseAvailable;

    if (firebaseAvailable) {
      try {
        await FirebaseService.to.syncUserData();
        final onlineUsers = await FirebaseService.to.fetchLeaderboard(limit: 50);

        if (onlineUsers.isNotEmpty) {
          _setOnlineLeaderboard(onlineUsers);
          isLoading.value = false;
          return;
        }
      } catch (e) {
        debugPrint('LeaderboardController: Online fetch failed: $e');
      }
    }

    // Fallback to local baseline if offline or Firebase not configured yet
    _buildLocalLeaderboard();
    isLoading.value = false;
  }

  void _setOnlineLeaderboard(List<LeaderboardUser> onlineUsers) {
    int userRank = 1;
    bool foundCurrent = false;

    for (var i = 0; i < onlineUsers.length; i++) {
      if (onlineUsers[i].isCurrentUser) {
        foundCurrent = true;
        userRank = onlineUsers[i].rank;
        break;
      }
    }

    if (!foundCurrent) {
      userRank = onlineUsers.length + 1;
    }

    leaderboardUsers.assignAll(onlineUsers);
    currentUserRank.value = userRank;
  }

  void _buildLocalLeaderboard() {
    final currentUserLevel = storage.unlockedLevel.value;
    final currentUserName = storage.getOrCreateUserName();

    // Standard World Dummy Players
    final rawWorldPlayers = [
      _TempUser('AquaKing_99', '👑', '🇺🇸', 1185, 400),
      _TempUser('SortMaster_Alex', '🦁', '🇩🇪', 1140, 390),
      _TempUser('Elena_Water', '🦊', '🇫🇷', 1090, 375),
      _TempUser('Rahul_AIS', '🐯', '🇮🇳', 1025, 350),
      _TempUser('DragonSlayer', '🐉', '🇯🇵', 980, 330),
      _TempUser('WaterQueen', '👸', '🇬🇧', 920, 310),
      _TempUser('Gamer_007', '🤖', '🇨🇦', 860, 290),
      _TempUser('Sofia_Aqua', '🦄', '🇧🇷', 810, 275),
      _TempUser('Vikram_India', '🦅', '🇮🇳', 760, 260),
      _TempUser('Lucas_Sort', '🐺', '🇪🇸', 710, 240),
      _TempUser('Priya_Fluid', '🌺', '🇮🇳', 650, 220),
      _TempUser('Master_Puzzler', '🧙', '🇦🇺', 590, 200),
      _TempUser('Aqua_Ninja', '🥷', '🇰🇷', 520, 180),
      _TempUser('Liquid_Pro', '⚡', '🇮🇹', 450, 150),
      _TempUser('Ocean_Explorer', '🐬', '🇲🇽', 380, 130),
    ];

    // Add Current User
    rawWorldPlayers.add(_TempUser(
      '$currentUserName (You)',
      '🎮',
      '🇮🇳',
      userTotalStars.value,
      currentUserLevel,
      isCurrentUser: true,
    ));

    // Sort descending by stars, then level
    rawWorldPlayers.sort((a, b) {
      if (b.stars != a.stars) {
        return b.stars.compareTo(a.stars);
      }
      return b.level.compareTo(a.level);
    });

    // Assign final ranks
    final sortedList = <LeaderboardUser>[];
    int userCalculatedRank = 1;

    for (var i = 0; i < rawWorldPlayers.length; i++) {
      final p = rawWorldPlayers[i];
      final rank = i + 1;
      if (p.isCurrentUser) {
        userCalculatedRank = rank;
      }
      sortedList.add(LeaderboardUser(
        rank: rank,
        name: p.name,
        avatarEmoji: p.avatarEmoji,
        countryFlag: p.countryFlag,
        stars: p.stars,
        level: p.level,
        isCurrentUser: p.isCurrentUser,
      ));
    }

    leaderboardUsers.assignAll(sortedList);
    currentUserRank.value = userCalculatedRank;
  }

  void onBackPressed() {
    AudioService.to.playButtonClick();
    Get.back();
  }

  void refreshLeaderboard() {
    _loadLeaderboardData();
  }
}

class _TempUser {
  final String name;
  final String avatarEmoji;
  final String countryFlag;
  final int stars;
  final int level;
  final bool isCurrentUser;

  _TempUser(
    this.name,
    this.avatarEmoji,
    this.countryFlag,
    this.stars,
    this.level, {
    this.isCurrentUser = false,
  });
}
