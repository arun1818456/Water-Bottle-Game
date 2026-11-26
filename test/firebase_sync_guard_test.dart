import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/services/firebase_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await Get.putAsync(() => StorageService().init());
  });

  group('Cloud Sync & Auth Desync Guards', () {
    test('setUserName and setUserPhotoUrl respect notifyCloud flag', () async {
      final storage = StorageService.to;
      int callbackCount = 0;
      storage.onDataChanged = () => callbackCount++;

      await storage.setUserName('Hydrated Name', notifyCloud: false);
      await storage.setUserPhotoUrl('https://example.com/p.png', notifyCloud: false);
      expect(callbackCount, equals(0));

      await storage.setUserName('Edited Name');
      await storage.setUserPhotoUrl('https://example.com/p2.png');
      expect(callbackCount, equals(2));
    });

    test('FirebaseService.isUserLoggedIn does not fall back to stale userEmail', () async {
      await StorageService.to.setUserEmail('stale@gmail.com');
      final firebaseService = Get.put(FirebaseService());

      expect(firebaseService.currentUser, isNull);
      expect(firebaseService.isUserLoggedIn, isFalse);

      // Should safely no-op without mutating or throwing
      await firebaseService.syncUserData(force: true);
      await firebaseService.flushPendingSync();
    });

    test('resetGameProgressForSignOut clears stale auth/progress while keeping local audio/tutorial settings', () async {
      final storage = StorageService.to;
      await storage.setSoundEnabled(false);
      await storage.completeTutorial();
      await storage.setUserEmail('player@gmail.com');
      await storage.setLastSignedInUid('uid-123');
      await storage.completeLevel(1, 3);
      await storage.addCoins(250);

      await storage.resetGameProgressForSignOut();

      expect(storage.userEmail.value, isEmpty);
      expect(storage.getLastSignedInUid(), isEmpty);
      expect(storage.unlockedLevel.value, equals(1));
      expect(storage.coins.value, equals(100));
      expect(storage.levelStars, isEmpty);
      // Device preferences preserved
      expect(storage.soundEnabled.value, isFalse);
      expect(storage.tutorialCompleted.value, isTrue);
    });
  });
}
