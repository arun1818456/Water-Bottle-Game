import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_bottle_ais/exports.dart';

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

    await tester.tap(find.byType(BottleWidget));
    await tester.pump();

    expect(tapped, isTrue);

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

    await tester.pump(const Duration(milliseconds: 600));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('HomeScreen renders play button and navigation options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeScreen(),
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
