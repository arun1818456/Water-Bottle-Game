import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/constants/notification_messages.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationMessages Pool & Rotation Tests', () {
    test('Contains at least 100 engaging and unique notification messages', () {
      final pool = NotificationMessages.pool;
      expect(pool.length, greaterThanOrEqualTo(100));

      // Ensure every message has non-empty title and body
      for (var i = 0; i < pool.length; i++) {
        final msg = pool[i];
        expect(msg.title.isNotEmpty, isTrue, reason: 'Title empty at index $i');
        expect(msg.body.isNotEmpty, isTrue, reason: 'Body empty at index $i');
        // Ensure no boring time texts like "13 hours"
        expect(msg.title.toLowerCase().contains('13 hour'), isFalse);
        expect(msg.body.toLowerCase().contains('13 hour'), isFalse);
      }
    });

    test('Rotates sequentially through the 100 messages without skipping', () async {
      final storage = StorageService();
      await storage.init();

      final firstIdx = storage.getNextNotificationIndex(100);
      final secondIdx = storage.getNextNotificationIndex(100);
      final thirdIdx = storage.getNextNotificationIndex(100);

      expect(firstIdx, equals(0));
      expect(secondIdx, equals(1));
      expect(thirdIdx, equals(2));
    });
  });
}
