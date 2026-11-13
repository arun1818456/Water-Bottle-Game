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
  final RxInt currentUserRank = 0.obs;
  final RxInt userTotalStars = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUserLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    isLoading.value = true;
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

    // User is logged in: sync user stats first, then fetch dynamic global players from Firestore
    if (firebaseService != null && firebaseService.isInitialized) {
      try {
        await firebaseService.syncUserData(force: true);
        final onlineUsers = await firebaseService.fetchLeaderboard(limit: 50);

        if (onlineUsers.isNotEmpty) {
          _setOnlineLeaderboard(onlineUsers);
        } else {
          // If Firestore collection has only the current user
          _setSingleUserLeaderboard();
        }
      } catch (e) {
        debugPrint('LeaderboardController: Online fetch failed: $e');
        _setSingleUserLeaderboard();
      }
    } else {
      _setSingleUserLeaderboard();
    }

    isLoading.value = false;
  }

  void _setSingleUserLeaderboard() {
    final currentUserName = storage.getOrCreateUserName();
    final avatar = storage.getOrCreateUserAvatar();
    final user = LeaderboardUser(
      rank: 1,
      name: '$currentUserName (You)',
      avatarEmoji: avatar,
      countryFlag: '🇮🇳',
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

  void onBackPressed() {
    AudioService.to.playButtonClick();
    Get.back();
  }

  void refreshLeaderboard({bool invalidateCache = false}) {
    if (invalidateCache && Get.isRegistered<FirebaseService>()) {
      FirebaseService.to.invalidateLeaderboardCache();
    }
    _loadLeaderboardData();
  }
}
