import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/storage_service.dart';
import '../../features/leaderboard/leaderboard_controller.dart';

/// FirebaseService manages Firebase authentication, Direct Google Sign-In,
/// and Zero-Cost Free-Tier Cloud Firestore synchronization.
///
/// OPTION A ARCHITECTURE (Zero Cost / Spark Plan Friendly):
/// - Guest users write 0 documents to Firestore (all data remains in local storage).
/// - Cloud sync ONLY activates for users authenticated with Google.
/// - Writes are debounced and batched to session pauses / milestone triggers
///   (max ~1 write per session) saving 95%+ of Firestore write quota.
/// - Leaderboard queries are cached for 10 minutes to conserve read quota.
class FirebaseService extends GetxService with WidgetsBindingObserver {
  static FirebaseService get to => Get.find<FirebaseService>();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseFirestore? _db;
  FirebaseAuth? _auth;

  FirebaseAuth? get auth => _auth;
  User? get currentUser => _auth?.currentUser;
  bool get isUserLoggedIn => _auth?.currentUser != null || (Get.isRegistered<StorageService>() && StorageService.to.userEmail.value.isNotEmpty);

  // Throttling & Zero-Cost Sync Tracking
  bool _isCloudDirty = false;
  DateTime? _lastSyncTime;
  static const Duration _minSyncInterval = Duration(minutes: 3);

  // Leaderboard In-Memory Cache (Conserves Read Quota)
  List<LeaderboardUser>? _cachedLeaderboard;
  DateTime? _lastLeaderboardFetchTime;
  static const Duration _leaderboardCacheDuration = Duration(minutes: 10);

  Future<FirebaseService> init() async {
    try {
      await Firebase.initializeApp();
      _db = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _isInitialized = true;
      debugPrint('FirebaseService: Initialized successfully with Zero-Cost Spark configuration.');

      // Register lifecycle observer to flush sync when user pauses / exits app
      WidgetsBinding.instance.addObserver(this);

      // Connect local storage mutations to dirty flag
      StorageService.to.onDataChanged = markDirty;

      // Listen to auth state changes
      _auth?.authStateChanges().listen((user) async {
        if (user != null) {
          if (user.email != null && user.email!.isNotEmpty) {
            StorageService.to.setUserEmail(user.email!);
          }
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            StorageService.to.setUserName(user.displayName!);
          }
          // On app launch with existing signed-in user, fetch and restore cloud data first!
          await restoreCloudData();
        }
      });

      // If user is already authenticated from a previous session, restore cloud progress on startup
      if (isUserLoggedIn) {
        await restoreCloudData();
      }
    } catch (e) {
      debugPrint('FirebaseService: Initialization skipped or google-services.json not found: $e');
      _isInitialized = false;
    }
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app is minimized, put to background, or closed, flush any pending dirty data
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        flushPendingSync();
        break;
      default:
        break;
    }
  }

  /// Marks in-memory dirty flag without making an immediate Firestore write call
  void markDirty() {
    if (isUserLoggedIn) {
      _isCloudDirty = true;
    }
  }

  /// Flushes pending changes immediately (e.g. on app pause or important milestones)
  Future<void> flushPendingSync() async {
    if (_isCloudDirty && isUserLoggedIn) {
      await syncUserData(force: true);
    }
  }

  /// Restores progress from Firestore for the currently logged-in user
  Future<void> restoreCloudData() async {
    if (!_isInitialized || _db == null || !isUserLoggedIn) return;

    try {
      final userId = currentUser?.uid;
      if (userId == null) return;

      final docRef = _db!.collection('users').doc(userId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        await StorageService.to.mergeAndRestoreFromCloudMap(doc.data()!);
        debugPrint('FirebaseService: Cloud progress restored on launch for $userId.');
      } else {
        // Initial cloud profile if doc doesn't exist yet
        await syncUserData(force: true);
      }
    } catch (e) {
      debugPrint('FirebaseService: restoreCloudData error: $e');
    }
  }

  /// Syncs player's progress to Firestore document `users/{userId}`.
  /// Enforces Option A: Guest users never write to Firestore (0 quota used).
  /// Debounces frequent calls to conserve the 20,000 writes/day free limit.
  Future<void> syncUserData({bool force = false}) async {
    if (!_isInitialized || _db == null) return;

    // OPTION A RULE: Only logged-in users backup to cloud
    if (!isUserLoggedIn) {
      debugPrint('FirebaseService: Guest user. Firestore write skipped (Zero-Cost Free Plan).');
      return;
    }

    // Skip if nothing changed and not forced
    if (!force && !_isCloudDirty) {
      return;
    }

    // Throttling: prevent rapid repeated writes within 3 minutes unless forced
    final now = DateTime.now();
    if (!force && _lastSyncTime != null && now.difference(_lastSyncTime!) < _minSyncInterval) {
      debugPrint('FirebaseService: Write debounced (saving quota). Will sync on session pause.');
      return;
    }

    try {
      final storage = StorageService.to;
      final userId = currentUser?.uid ?? storage.getOrCreateUserId();
      final userName = storage.getOrCreateUserName();
      final userAvatar = storage.getOrCreateUserAvatar();
      final totalStars = storage.totalStarsCollected;

      // Complete compact payload in a single document
      final Map<String, dynamic> data = {
        'userId': userId,
        'userName': userName,
        'avatarEmoji': userAvatar,
        'countryFlag': '🇮🇳',
        'email': storage.userEmail.value,
        'coins': storage.coins.value,
        'unlockedLevel': storage.unlockedLevel.value,
        'completedCount': storage.completedCount.value,
        'totalStars': totalStars,
        'levelStars': storage.levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'unlockedBottleSkins': storage.unlockedBottleSkins.toList(),
        'equippedBottleSkin': storage.equippedBottleSkin.value,
        'unlockedBackgrounds': storage.unlockedBackgrounds.toList(),
        'equippedBackground': storage.equippedBackground.value,
        'dailyStreak': storage.dailyStreak.value,
        'lastDailyClaimDate': storage.lastDailyClaimDate.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db!.collection('users').doc(userId).set(data, SetOptions(merge: true));
      _isCloudDirty = false;
      _lastSyncTime = now;
      debugPrint('FirebaseService: Cloud progress saved successfully for $userId.');
    } catch (e) {
      debugPrint('FirebaseService: syncUserData error: $e');
    }
  }

  /// Direct One-Tap Google Sign-In with Smart Non-Destructive Cloud Merge:
  /// - New user: Backs up current local progress to new cloud profile.
  /// - Existing user: Merges local and cloud progress taking the best levels,
  ///   highest coins, highest stars, and union of cosmetics.
  Future<String?> signInWithGoogle() async {
    if (!_isInitialized || _auth == null) {
      return 'Firebase is not initialized yet. Please place google-services.json in android/app/';
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return 'Google Sign-In canceled.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCred = await _auth!.signInWithCredential(credential);
      final User? user = userCred.user;

      if (user != null) {
        final userId = user.uid;
        final email = user.email ?? '';
        final displayName = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Player';

        await StorageService.to.setUserEmail(email);

        // Check if user already has cloud progress in Firestore
        final userDocRef = _db!.collection('users').doc(userId);
        final docSnapshot = await userDocRef.get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          // EXISTING USER: Restore and merge without data loss
          await StorageService.to.mergeAndRestoreFromCloudMap(docSnapshot.data()!);
          // Write merged state back so Cloud has full updated profile
          await syncUserData(force: true);
          debugPrint('FirebaseService: Cloud data merged and restored for $userId.');
        } else {
          // NEW USER: Initial cloud profile created with current local progress
          if (StorageService.to.getOrCreateUserName().startsWith('Player_')) {
            await StorageService.to.setUserName(displayName);
          }
          await syncUserData(force: true);
          debugPrint('FirebaseService: New cloud profile created for $userId.');
        }

        // Invalidate leaderboard cache so refreshed ranks reflect newly logged-in user
        invalidateLeaderboardCache();

        return null; // Success!
      }

      return 'Failed to get user details from Google.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google Sign-In failed.';
    } catch (e) {
      return 'Google Sign-In error: $e';
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await _auth?.signOut();
      await StorageService.to.setUserEmail('');
      invalidateLeaderboardCache();
    } catch (e) {
      debugPrint('FirebaseService: signOut error: $e');
    }
  }

  /// Clears in-memory leaderboard cache
  void invalidateLeaderboardCache() {
    _cachedLeaderboard = null;
    _lastLeaderboardFetchTime = null;
  }

  /// Fetches top players with a 10-minute in-memory cache to conserve Firestore read quota
  Future<List<LeaderboardUser>> fetchLeaderboard({int limit = 50}) async {
    // 1. Check in-memory cache
    final now = DateTime.now();
    if (_cachedLeaderboard != null &&
        _lastLeaderboardFetchTime != null &&
        now.difference(_lastLeaderboardFetchTime!) < _leaderboardCacheDuration) {
      debugPrint('FirebaseService: Returning cached leaderboard (0 Firestore reads).');
      return _cachedLeaderboard!;
    }

    if (!_isInitialized || _db == null) return [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      try {
        querySnapshot = await _db!
            .collection('users')
            .orderBy('totalStars', descending: true)
            .limit(limit)
            .get();
      } catch (err) {
        debugPrint('FirebaseService: orderBy totalStars failed, falling back to simple get: $err');
        querySnapshot = await _db!.collection('users').limit(limit).get();
      }

      final currentUserId = currentUser?.uid;
      final List<LeaderboardUser> users = [];

      final docs = querySnapshot.docs.toList();
      // Always sort descending by totalStars in client memory for maximum robustness
      docs.sort((a, b) {
        final aStars = (a.data()['totalStars'] as int?) ?? 0;
        final bStars = (b.data()['totalStars'] as int?) ?? 0;
        return bStars.compareTo(aStars);
      });

      for (var i = 0; i < docs.length; i++) {
        final doc = docs[i];
        final data = doc.data();

        final uId = data['userId'] as String? ?? doc.id;
        final name = data['userName'] as String? ?? 'Player';
        final emoji = data['avatarEmoji'] as String? ?? '🎮';
        final flag = data['countryFlag'] as String? ?? '🇮🇳';
        final stars = data['totalStars'] as int? ?? 0;
        final level = data['unlockedLevel'] as int? ?? 1;

        final isCurrent = currentUserId != null && uId == currentUserId;

        users.add(LeaderboardUser(
          rank: i + 1,
          name: isCurrent ? '$name (You)' : name,
          avatarEmoji: emoji,
          countryFlag: flag,
          stars: stars,
          level: level,
          isCurrentUser: isCurrent,
        ));
      }

      // If current user is logged in but not in top returned results, insert them
      if (currentUserId != null && !users.any((u) => u.isCurrentUser)) {
        final storage = StorageService.to;
        final myStars = storage.totalStarsCollected;
        final myLevel = storage.unlockedLevel.value;
        final myName = storage.getOrCreateUserName();
        final myAvatar = storage.getOrCreateUserAvatar();

        int insertIndex = users.indexWhere((u) => u.stars <= myStars);
        if (insertIndex == -1) insertIndex = users.length;

        users.insert(
          insertIndex,
          LeaderboardUser(
            rank: insertIndex + 1,
            name: '$myName (You)',
            avatarEmoji: myAvatar,
            countryFlag: '🇮🇳',
            stars: myStars,
            level: myLevel,
            isCurrentUser: true,
          ),
        );

        // Normalize ranks
        for (var j = 0; j < users.length; j++) {
          final u = users[j];
          users[j] = LeaderboardUser(
            rank: j + 1,
            name: u.name,
            avatarEmoji: u.avatarEmoji,
            countryFlag: u.countryFlag,
            stars: u.stars,
            level: u.level,
            isCurrentUser: u.isCurrentUser,
          );
        }
      }

      // Update cache
      _cachedLeaderboard = users;
      _lastLeaderboardFetchTime = now;
      return users;
    } catch (e) {
      debugPrint('FirebaseService: fetchLeaderboard error: $e');
      return _cachedLeaderboard ?? [];
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
