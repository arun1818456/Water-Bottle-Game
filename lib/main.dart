import 'exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await onInitMethod();
  runApp(const MyApp());
}

Future<void> onInitMethod() async {
  // Lock orientation to portrait for optimal puzzle casual play
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AudioService().init());
  // await Get.putAsync(() => AdsService().init());
}
