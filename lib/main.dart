import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ads_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_reward/daily_reward_view.dart';
import 'features/game/game_view.dart';
import 'features/home/home_view.dart';
import 'features/levels/level_select_view.dart';
import 'features/shop/shop_view.dart';
import 'features/settings/settings_view.dart';
import 'features/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await Get.putAsync(() => AdsService().init());

  runApp(const AquaSortMasterApp());
}

class AquaSortMasterApp extends StatelessWidget {
  const AquaSortMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/game',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final lvlId = args?['levelId'] as int?;
            return GameView(levelId: lvlId);
          },
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/levels',
          page: () => const LevelSelectView(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/shop',
          page: () => const ShopView(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/daily-reward',
          page: () => const DailyRewardView(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsView(),
          transition: Transition.rightToLeftWithFade,
        ),
      ],
    );
  }
}
