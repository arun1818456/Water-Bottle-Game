import 'package:water_bottle_ais/exports.dart';

class LevelController extends GetxController {
  final storage = StorageService.to;
  final RxInt selectedTab = 0.obs;

  final List<String> difficultyTabs = [
    'All',
    'Easy (1-20)',
    'Easy+ (21-40)',
    'Medium (41-60)',
    'Hard (61-80)',
    'Expert (81-100)',
    'Master (101-120)',
  ];

  List<int> get filteredLevelIds {
    switch (selectedTab.value) {
      case 1:
        return List.generate(20, (i) => i + 1);
      case 2:
        return List.generate(20, (i) => i + 21);
      case 3:
        return List.generate(20, (i) => i + 41);
      case 4:
        return List.generate(20, (i) => i + 61);
      case 5:
        return List.generate(20, (i) => i + 81);
      case 6:
        return List.generate(20, (i) => i + 101);
      case 0:
      default:
        return List.generate(AppConstants.totalHandcraftedLevels, (i) => i + 1);
    }
  }

  void selectTab(int index) {
    AudioService.to.playButtonClick();
    selectedTab.value = index;
  }

  void onLevelTapped(int levelId) {
    if (!storage.isLevelUnlocked(levelId)) return;
    AudioService.to.playButtonClick();
    Get.toNamed(AppRoutes.gameScreen, arguments: {'levelId': levelId});
  }
}
