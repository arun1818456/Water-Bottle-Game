import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';
import 'package:water_bottle_ais/core/services/audio_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';
import 'package:water_bottle_ais/features/game/widgets/bottle_widget.dart';
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

    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => AudioService().init());
    // await Get.putAsync(() => AdsService().init());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('BottleWidget renders with liquid layers and responds to tap',
      (WidgetTester tester) async {
    var tapped = false;
    final bottle = Bottle(layers: [1, 2, 3]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottleWidget(
            bottle: bottle,
            index: 0,
            isSelected: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(BottleWidget), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Tap bottle
    await tester.tap(find.byType(BottleWidget));
    await tester.pump();

    expect(tapped, isTrue);

    // Cleanly unmount to cancel repeating wave animation
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('BottleWidget animates cap and sparkles when completed with single color',
      (WidgetTester tester) async {
    final completedBottle = Bottle(layers: [2, 2, 2, 2]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottleWidget(
            bottle: completedBottle,
            index: 0,
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(BottleWidget), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Let animations settle
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('HomeView renders play button and navigation options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeView(),
      ),
    );

    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
