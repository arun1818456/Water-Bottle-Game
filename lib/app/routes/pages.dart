import '../../exports.dart';

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.tutorialScreen,
      page: () => const GameScreen(isTutorial: true),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.gameScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final lvlId = args?['levelId'] as int?;
        return GameScreen(levelId: lvlId);
      },
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.levelSelectScreen,
      page: () => const LevelSelectScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.shopScreen,
      page: () => const ShopScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.dailyRewardScreen,
      page: () => const DailyRewardScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.settingsScreen,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
