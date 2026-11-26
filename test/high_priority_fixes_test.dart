import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/core/services/ads_service.dart';
import 'package:water_bottle_ais/core/services/audio_service.dart';
import 'package:water_bottle_ais/core/services/notification_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/features/game/controllers/game_controller.dart';
import 'package:water_bottle_ais/features/game/game_view.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';
import 'package:water_bottle_ais/features/home/home_view.dart';

class _SpyNotificationService extends NotificationService {
  int scheduleCount = 0;
  int cancelCount = 0;

  @override
  Future<void> schedule13HourReminder() async {
    scheduleCount++;
  }

  @override
  Future<void> cancelReminder() async {
    cancelCount++;
  }
}

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
      'asm_tutorial_completed': true,
    });
    Get.reset();
    Get.testMode = true;
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => AudioService().init());
    await Get.putAsync(() => AdsService().init());
  });

  tearDown(() {
    Get.reset();
  });

  test('AudioService ignores inactive for reminders and schedules once per background transition', () {
    final spyNotif = Get.put<NotificationService>(_SpyNotificationService()) as _SpyNotificationService;
    final audio = AudioService.to;

    // System dialog / ad overlay -> inactive should NOT schedule reminder
    audio.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(spyNotif.scheduleCount, equals(0));

    // App backgrounded: hidden -> paused -> detached should schedule only ONCE
    audio.didChangeAppLifecycleState(AppLifecycleState.hidden);
    audio.didChangeAppLifecycleState(AppLifecycleState.paused);
    audio.didChangeAppLifecycleState(AppLifecycleState.detached);
    expect(spyNotif.scheduleCount, equals(1));

    // App resumed: cancels reminder and resets guard
    audio.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(spyNotif.cancelCount, equals(1));

    // Next background transition schedules again
    audio.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(spyNotif.scheduleCount, equals(2));
  });

  testWidgets('HomeView exit dialog uses SystemNavigator.pop instead of exit(0)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    bool popCalled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'SystemNavigator.pop') {
          popCalled = true;
        }
        return null;
      },
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump(const Duration(milliseconds: 100));

    // Trigger back press on HomeView
    await Get.key.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Exit Game?'), findsOneWidget);

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(find.text('Exit Game?'), findsNothing);
    expect(popCalled, isTrue);

    debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Pour stream and overlay stay aligned when FittedBox scales down a 14-bottle board', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: GameView(levelId: 1),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final controller = Get.find<GameController>();
    // Replace board with 14 bottles so FittedBox scales the grid down on 320px width
    controller.bottles.assignAll([
      Bottle(layers: [2, 2, 1, 1]),
      Bottle(layers: [1, 1]),
      ...List.generate(12, (_) => Bottle(layers: [3, 3, 4, 4])),
    ]);
    await tester.pump(const Duration(milliseconds: 50));

    final stackBox = controller.gameStackKey.currentContext!.findRenderObject() as RenderBox;
    final targetBox = controller.getBottleKey(1).currentContext!.findRenderObject() as RenderBox;
    final targetTopLeft = stackBox.globalToLocal(targetBox.localToGlobal(Offset.zero));
    final targetTopRight = stackBox.globalToLocal(
      targetBox.localToGlobal(Offset(targetBox.size.width, 0)),
    );
    final actualVisualCenterX = (targetTopLeft.dx + targetTopRight.dx) / 2;

    // Tap bottle 0 then bottle 1 to start pour
    controller.onBottleTapped(0);
    await tester.pump();
    controller.onBottleTapped(1);
    await tester.pump(const Duration(milliseconds: 80));

    expect(controller.isPouring.value, isTrue);
    expect(controller.streamEnd.value.dx, closeTo(actualVisualCenterX, 0.5));
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('PUZZLE STUCK!'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('RESTART LEVEL'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
