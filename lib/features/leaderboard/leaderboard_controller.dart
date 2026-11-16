import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final String photoUrl;
  final String avatarEmoji;
  final String countryFlag;
  final int stars;
  final int level;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.rank,
    required this.name,
    this.photoUrl = '',
    this.avatarEmoji = '🎮',
    required this.countryFlag,
    required this.stars,
    required this.level,
    this.isCurrentUser = false,
  });
}

class LeaderboardController extends GetxController {
  final storage = StorageService.to;

  final RxList<LeaderboardUser> leaderboardUsers = <LeaderboardUser>[].obs;
  final RxInt currentUserRank = 0.obs;
  final RxInt userTotalStars = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUserLoggedIn = false.obs;

  // Rank climbing animation tracking
  final RxInt previousUserRank = 0.obs;
  final RxBool hasRankClimbed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData({bool silent = false}) async {
    // Only show full-screen loader if we have zero cached players in memory
    if (!silent && leaderboardUsers.isEmpty) {
      isLoading.value = true;
    }

    userTotalStars.value = storage.totalStarsCollected;

    final firebaseService = Get.isRegistered<FirebaseService>() ? FirebaseService.to : null;
    final loggedIn = (firebaseService?.isUserLoggedIn ?? false) || storage.userEmail.value.isNotEmpty;
    isUserLoggedIn.value = loggedIn;

    // If user is not logged in, we do not show dummy/static data!
    if (!loggedIn) {
      leaderboardUsers.clear();
      currentUserRank.value = 0;
      isLoading.value = false;
      return;
    }

    // User is logged in: sync user stats (debounced, force: false to save free quota)
    if (firebaseService != null && firebaseService.isInitialized) {
      try {
        // Zero-cost: Only write if player actually has unsynced progress
        await firebaseService.syncUserData(force: false);
        final onlineUsers = await firebaseService.fetchLeaderboard(limit: 50);

        if (onlineUsers.isNotEmpty) {
          _setOnlineLeaderboard(onlineUsers);
        } else {
          _setSingleUserLeaderboard();
        }
      } catch (e) {
        debugPrint('LeaderboardController: Online fetch failed: $e');
        if (leaderboardUsers.isEmpty) {
          _setSingleUserLeaderboard();
        }
      }
    } else {
      if (leaderboardUsers.isEmpty) {
        _setSingleUserLeaderboard();
      }
    }

    isLoading.value = false;
  }

  void _setSingleUserLeaderboard() {
    final currentUserName = storage.getOrCreateUserName();
    final photoUrl = storage.userPhotoUrl.value;
    final countryFlag = storage.getOrCreateCountryFlag();
    final user = LeaderboardUser(
      rank: 1,
      name: '$currentUserName (You)',
      photoUrl: photoUrl,
      avatarEmoji: '🎮',
      countryFlag: countryFlag,
      stars: userTotalStars.value,
      level: storage.unlockedLevel.value,
      isCurrentUser: true,
    );
    leaderboardUsers.assignAll([user]);
    currentUserRank.value = 1;
  }

  void _setOnlineLeaderboard(List<LeaderboardUser> onlineUsers) {
    int userRank = 1;
    bool foundCurrent = false;

    // Synchronize current user's local real-time stars and level
    final myStars = storage.totalStarsCollected;
    final myLevel = storage.unlockedLevel.value;
    final myPhoto = storage.userPhotoUrl.value;
    final myFlag = storage.getOrCreateCountryFlag();
    final myName = storage.getOrCreateUserName();

    final List<LeaderboardUser> updatedList = [];

    for (var i = 0; i < onlineUsers.length; i++) {
      final u = onlineUsers[i];
      if (u.isCurrentUser) {
        foundCurrent = true;
        // Always take the latest local stars and level if higher or updated!
        final resolvedStars = myStars > u.stars ? myStars : u.stars;
        final resolvedLevel = myLevel > u.level ? myLevel : u.level;
        updatedList.add(LeaderboardUser(
          rank: u.rank,
          name: u.name,
          photoUrl: myPhoto.isNotEmpty ? myPhoto : u.photoUrl,
          avatarEmoji: u.avatarEmoji,
          countryFlag: myFlag,
          stars: resolvedStars,
          level: resolvedLevel,
          isCurrentUser: true,
        ));
      } else {
        updatedList.add(u);
      }
    }

    if (!foundCurrent) {
      updatedList.add(LeaderboardUser(
        rank: updatedList.length + 1,
        name: '$myName (You)',
        photoUrl: myPhoto,
        avatarEmoji: '🎮',
        countryFlag: myFlag,
        stars: myStars,
        level: myLevel,
        isCurrentUser: true,
      ));
    }

    // Sort by stars descending to keep accurate ranks
    updatedList.sort((a, b) => b.stars.compareTo(a.stars));

    // Re-assign 1-based ranks
    for (var j = 0; j < updatedList.length; j++) {
      final u = updatedList[j];
      final newRank = j + 1;
      if (u.isCurrentUser) {
        userRank = newRank;
      }
      updatedList[j] = LeaderboardUser(
        rank: newRank,
        name: u.name,
        photoUrl: u.photoUrl,
        avatarEmoji: u.avatarEmoji,
        countryFlag: u.countryFlag,
        stars: u.stars,
        level: u.level,
        isCurrentUser: u.isCurrentUser,
      );
    }

    // Check rank climbing effect
    final lastRank = storage.getLastLeaderboardRank();
    if (lastRank > 0 && userRank < lastRank) {
      previousUserRank.value = lastRank;
      hasRankClimbed.value = true;
    } else {
      hasRankClimbed.value = false;
      previousUserRank.value = userRank;
    }

    storage.setLastLeaderboardRank(userRank);
    leaderboardUsers.assignAll(updatedList);
    currentUserRank.value = userRank;
  }

  void onBackPressed() {
    AudioService.to.playButtonClick();
    Get.back();
  }

  void refreshLeaderboard({bool invalidateCache = false}) {
    if (invalidateCache && Get.isRegistered<FirebaseService>()) {
      FirebaseService.to.invalidateLeaderboardCache();
    }
    // Silent refresh so that existing leaderboard data remains visible without flashing a loader
    _loadLeaderboardData(silent: leaderboardUsers.isNotEmpty);
  }
}
