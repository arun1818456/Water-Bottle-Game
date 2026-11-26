import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/services/ads_service.dart';
import 'package:water_bottle_ais/core/services/audio_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/game/widgets/defeat_dialog.dart';
import 'package:water_bottle_ais/features/game/widgets/victory_dialog.dart';

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
    await Get.putAsync(() => AdsService().init());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('VictoryDialog ignores system back pop and closes on NEXT LEVEL',
      (WidgetTester tester) async {
    var nextLevelCalled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Get.dialog(
                  VictoryDialog(
                    levelId: 1,
                    stars: 3,
                    baseCoins: 0,
                    onNextLevel: () => nextLevelCalled = true,
                    onRestart: () {},
                    onHome: () {},
                  ),
                  barrierDismissible: false,
                );
              },
              child: const Text('Open Victory'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Victory'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('VICTORY!'), findsOneWidget);

    // Simulate system back button (maybePop)
    final handled = await Get.key.currentState!.maybePop();
    await tester.pump();

    expect(handled, isTrue);
    expect(find.text('VICTORY!'), findsOneWidget);

    // Explicit CTA still closes the dialog and triggers callback
    await tester.tap(find.text('NEXT LEVEL'));
    await tester.pumpAndSettle();

    expect(nextLevelCalled, isTrue);
    expect(find.text('VICTORY!'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('DefeatDialog ignores system back pop and closes on RESTART LEVEL',
      (WidgetTester tester) async {
    var restartCalled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Get.dialog(
                  DefeatDialog(
                    onUndo: () {},
                    onRestart: () => restartCalled = true,
                    onAddBottle: () {},
                  ),
                  barrierDismissible: false,
                );
              },
              child: const Text('Open Defeat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Defeat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('PUZZLE STUCK!'), findsOneWidget);

    // Simulate system back button (maybePop)
    final handled = await Get.key.currentState!.maybePop();
    await tester.pump();

    expect(handled, isTrue);
    expect(find.text('PUZZLE STUCK!'), findsOneWidget);

    // Explicit CTA still closes the dialog and triggers callback
    await tester.tap(find.text('RESTART LEVEL'));
    await tester.pumpAndSettle();

    expect(restartCalled, isTrue);
    expect(find.text('PUZZLE STUCK!'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
