import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/storage_service.dart';
import '../../features/leaderboard/leaderboard_controller.dart';

/// FirebaseService manages Firebase initialization, Direct Google Sign-In,
/// Cloud Firestore Progress Restoration/Sync, and live online Leaderboard queries.
class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find<FirebaseService>();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseFirestore? _db;
  FirebaseAuth? _auth;

  FirebaseAuth? get auth => _auth;
  User? get currentUser => _auth?.currentUser;

  Future<FirebaseService> init() async {
    try {
      await Firebase.initializeApp();
      _db = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _isInitialized = true;
      debugPrint('FirebaseService: Initialized successfully.');

      // Listen to auth state changes
      _auth?.authStateChanges().listen((user) {
        if (user != null) {
          if (user.email != null && user.email!.isNotEmpty) {
            StorageService.to.setUserEmail(user.email!);
          }
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            StorageService.to.setUserName(user.displayName!);
          }
          syncUserData();
        }
      });

      // Auto-sync player progress to Firebase on startup
      syncUserData();
    } catch (e) {
      debugPrint('FirebaseService: Initialization skipped or google-services.json not found: $e');
      _isInitialized = false;
    }
    return this;
  }

  /// Syncs player's local progress (Coins, Level, Stars, Name, Avatar) to Firestore document `users/{userId}`
  Future<void> syncUserData() async {
    if (!_isInitialized || _db == null) return;

    try {
      final storage = StorageService.to;
      final userId = currentUser?.uid ?? storage.getOrCreateUserId();
      final userName = storage.getOrCreateUserName();
      final userAvatar = storage.getOrCreateUserAvatar();

      // Calculate total stars collected
      final totalStars = storage.totalStarsCollected;

      final Map<String, dynamic> data = {
        'userId': userId,
        'userName': userName,
        'avatarEmoji': userAvatar,
        'countryFlag': '🇮🇳',
        'email': storage.userEmail.value,
        'coins': storage.coins.value,
        'unlockedLevel': storage.unlockedLevel.value,
        'totalStars': totalStars,
        'levelStars': storage.levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db!.collection('users').doc(userId).set(data, SetOptions(merge: true));
      debugPrint('FirebaseService: User data synced for $userId.');
    } catch (e) {
      debugPrint('FirebaseService: syncUserData error: $e');
    }
  }

  /// Direct One-Tap Google Sign-In:
  /// - New user: Creates new user profile in Firestore.
  /// - Existing user: Collects/restores their progress (Coins, Levels, Stars) from Cloud Firestore.
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

        // Check if user already exists in Firestore
        final userDocRef = _db!.collection('users').doc(userId);
        final docSnapshot = await userDocRef.get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          // EXISTING USER: Restore data from Cloud
          await StorageService.to.restoreFromCloudMap(docSnapshot.data()!);
          debugPrint('FirebaseService: Existing user data collected & restored for $userId.');
        } else {
          // NEW USER: Create initial cloud profile
          await StorageService.to.setUserName(displayName);
          await syncUserData();
          debugPrint('FirebaseService: New user account created for $userId.');
        }

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
    } catch (e) {
      debugPrint('FirebaseService: signOut error: $e');
    }
  }

  /// Fetches top players sorted by totalStars descending from Firestore
  Future<List<LeaderboardUser>> fetchLeaderboard({int limit = 20}) async {
    if (!_isInitialized || _db == null) return [];

    try {
      final querySnapshot = await _db!
          .collection('users')
          .orderBy('totalStars', descending: true)
          .limit(limit)
          .get();

      final currentUserId = currentUser?.uid ?? StorageService.to.getOrCreateUserId();
      final List<LeaderboardUser> users = [];

      for (var i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();

        final uId = data['userId'] as String? ?? doc.id;
        final name = data['userName'] as String? ?? 'Player';
        final emoji = data['avatarEmoji'] as String? ?? '🎮';
        final flag = data['countryFlag'] as String? ?? '🇮🇳';
        final stars = data['totalStars'] as int? ?? 0;
        final level = data['unlockedLevel'] as int? ?? 1;

        users.add(LeaderboardUser(
          rank: i + 1,
          name: uId == currentUserId ? '$name (You)' : name,
          avatarEmoji: emoji,
          countryFlag: flag,
          stars: stars,
          level: level,
          isCurrentUser: uId == currentUserId,
        ));
      }

      return users;
    } catch (e) {
      debugPrint('FirebaseService: fetchLeaderboard error: $e');
      return [];
    }
  }
}
