import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:water_bottle_ais/core/services/audio_service.dart';
import 'package:water_bottle_ais/core/services/storage_service.dart';
import 'package:water_bottle_ais/core/widgets/internet_required_dialog.dart';

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
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('InternetRequiredDialog renders title, message and closes on Got It button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  InternetRequiredDialog.show(
                    title: 'Internet Required',
                    message: 'Internet connection is required to add an extra bottle.',
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('INTERNET REQUIRED'), findsOneWidget);
    expect(
      find.text('Internet connection is required to add an extra bottle.'),
      findsOneWidget,
    );
    expect(find.text('GOT IT'), findsOneWidget);

    // Tap GOT IT to dismiss
    await tester.tap(find.text('GOT IT'));
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.text('INTERNET REQUIRED'), findsNothing);
  });
}
