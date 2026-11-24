import 'dart:async';
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
  bool _isSigningIn = false;
  DateTime? _lastSyncTime;
  static const Duration _minSyncInterval = Duration(minutes: 3);
  Future<void>? _inFlightRestore;
  String? _restoredUidInSession;

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

      // Listen to auth state changes (emits current user once on subscribe)
      _auth?.authStateChanges().listen((user) async {
        if (user != null) {
          if (_isSigningIn) return;
          final lastUid = StorageService.to.getLastSignedInUid();
          if (lastUid.isNotEmpty && lastUid != user.uid) {
            await StorageService.to.resetGameProgressForSignOut();
          }
          await StorageService.to.setLastSignedInUid(user.uid);
          if (user.email != null && user.email!.isNotEmpty) {
            await StorageService.to.setUserEmail(user.email!);
          }
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            await StorageService.to.setUserName(user.displayName!);
          }
          if (user.photoURL != null && user.photoURL!.isNotEmpty) {
            await StorageService.to.setUserPhotoUrl(user.photoURL!);
          }
          // Fetch and restore cloud data (deduplicated against concurrent calls)
          await restoreCloudData();
        }
      });

      // Kick off initial restore without blocking app startup
      if (isUserLoggedIn) {
        unawaited(restoreCloudData());
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
  Future<void> restoreCloudData({bool force = false}) {
    if (!_isInitialized || _db == null || !isUserLoggedIn) {
      return Future.value();
    }
    final userId = currentUser?.uid;
    if (userId == null) return Future.value();
    if (!force && _restoredUidInSession == userId) {
      return Future.value();
    }
    if (_inFlightRestore != null) return _inFlightRestore!;

    _inFlightRestore = () async {
      try {
        final docRef = _db!.collection('users').doc(userId);
        final doc = await docRef.get();

        if (doc.exists && doc.data() != null) {
          await StorageService.to.mergeAndRestoreFromCloudMap(doc.data()!);
          debugPrint('FirebaseService: Cloud progress restored on launch for $userId.');
        } else {
          // Initial cloud profile if doc doesn't exist yet
          await syncUserData(force: true);
        }
        _restoredUidInSession = userId;
        if (StorageService.to.getCachedLeaderboard().isEmpty) {
          unawaited(fetchLeaderboard(limit: 50));
        }
      } catch (e) {
        debugPrint('FirebaseService: restoreCloudData error: $e');
      } finally {
        _inFlightRestore = null;
      }
    }();
    return _inFlightRestore!;
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
      final userPhoto = storage.userPhotoUrl.value;
      final totalStars = storage.totalStarsCollected;

      // Compact cloud payload: only important progress, leaderboard profile, and updatedAt
      final Map<String, dynamic> data = {
        'userName': userName,
        'photoUrl': userPhoto,
        'countryFlag': storage.getOrCreateCountryFlag(),
        'coins': storage.coins.value,
        'unlockedLevel': storage.unlockedLevel.value,
        'totalStars': totalStars,
        'levelStars': storage.levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'unlockedBottleSkins': storage.unlockedBottleSkins.toList(),
        'equippedBottleSkin': storage.equippedBottleSkin.value,
        'unlockedBackgrounds': storage.unlockedBackgrounds.toList(),
        'equippedBackground': storage.equippedBackground.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db!.collection('users').doc(userId).set(data);
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

    _isSigningIn = true;
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
        // Safety guard: if a different account was previously stored locally,
        // wipe its local progress before loading/creating the new account's data.
        final lastUid = StorageService.to.getLastSignedInUid();
        if (lastUid.isNotEmpty && lastUid != userId) {
          await StorageService.to.resetGameProgressForSignOut();
        }
        await StorageService.to.setLastSignedInUid(userId);

        final email = user.email ?? '';
        final displayName = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Player';
        final photoUrl = user.photoURL ?? '';

        await StorageService.to.setUserEmail(email);
        await StorageService.to.setUserName(displayName);
        await StorageService.to.setUserPhotoUrl(photoUrl);

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
          await syncUserData(force: true);
          debugPrint('FirebaseService: New cloud profile created for $userId.');
        }

        // Invalidate leaderboard cache and prime local offline cache with real users
        invalidateLeaderboardCache();
        unawaited(fetchLeaderboard(limit: 50));

        return null; // Success!
      }

      return 'Failed to get user details from Google.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google Sign-In failed.';
    } catch (e) {
      return 'Google Sign-In error: $e';
    } finally {
      _isSigningIn = false;
    }
  }

  /// Sign Out: flushes pending cloud backup, signs out of Google/Firebase,
  /// and clears local game progress so another account cannot inherit it.
  Future<void> signOut() async {
    try {
      if (_isCloudDirty && isUserLoggedIn) {
        await syncUserData(force: true);
      }
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await _auth?.signOut();
    } catch (e) {
      debugPrint('FirebaseService: signOut error: $e');
    } finally {
      await StorageService.to.resetGameProgressForSignOut();
      _isCloudDirty = false;
      _lastSyncTime = null;
      _restoredUidInSession = null;
      invalidateLeaderboardCache();
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

        final uId = doc.id;
        final name = data['userName'] as String? ?? 'Player';
        final photo = data['photoUrl'] as String? ?? '';
        final flag = data['countryFlag'] as String? ?? '🇮🇳';
        final stars = data['totalStars'] as int? ?? 0;
        final level = data['unlockedLevel'] as int? ?? 1;

        final isCurrent = currentUserId != null && uId == currentUserId;

        users.add(LeaderboardUser(
          rank: i + 1,
          name: isCurrent ? '$name (You)' : name,
          photoUrl: photo,
          avatarEmoji: '🎮',
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
        final myPhoto = storage.userPhotoUrl.value;
        final myFlag = storage.getOrCreateCountryFlag();

        int insertIndex = users.indexWhere((u) => u.stars <= myStars);
        if (insertIndex == -1) insertIndex = users.length;

        users.insert(
          insertIndex,
          LeaderboardUser(
            rank: insertIndex + 1,
            name: '$myName (You)',
            photoUrl: myPhoto,
            avatarEmoji: '🎮',
            countryFlag: myFlag,
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
            photoUrl: u.photoUrl,
            avatarEmoji: u.avatarEmoji,
            countryFlag: u.countryFlag,
            stars: u.stars,
            level: u.level,
            isCurrentUser: u.isCurrentUser,
          );
        }
      }

      // Update in-memory and persistent local cache for offline leaderboard & rank-up dialog
      _cachedLeaderboard = users;
      _lastLeaderboardFetchTime = now;
      if (users.isNotEmpty) {
        unawaited(StorageService.to.saveCachedLeaderboard(users));
      }
      return users;
    } catch (e) {
      debugPrint('FirebaseService: fetchLeaderboard error: $e');
      if (_cachedLeaderboard != null && _cachedLeaderboard!.isNotEmpty) {
        return _cachedLeaderboard!;
      }
      return StorageService.to.getCachedLeaderboard();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
