import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/services/ads_service.dart';
import 'package:water_bottle_ais/core/services/audio_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/home/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );

    SharedPreferences.setMockInitialValues({
      'asm_google_promo_shown': true,
      'asm_coins': 250,
      'asm_daily_streak': 12,
      'asm_unlocked_level': 7,
    });
    Get.testMode = true;
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => AudioService().init());
    await Get.putAsync(() => AdsService().init());
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpAtSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeView(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('HomeView renders all mockup elements on 360x740 without overflow',
      (WidgetTester tester) async {
    await pumpAtSize(tester, const Size(360, 740));

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Day Streak'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('Current Level 7'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('HomeView fits cleanly on compact 320x640 and tall 412x915 screens',
      (WidgetTester tester) async {
    await pumpAtSize(tester, const Size(320, 640));
    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpAtSize(tester, const Size(412, 915));
    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
