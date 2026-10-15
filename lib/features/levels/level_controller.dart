import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class LevelController extends GetxController {
  final storage = StorageService.to;
  final RxInt selectedTab = 0.obs;

  List<int> get filteredLevelIds {
    return List.generate(AppConstants.totalHandcraftedLevels, (i) => i + 1);
  }

  void selectTab(int index) {
    AudioService.to.playButtonClick();
    selectedTab.value = index;
  }

  void onLevelTapped(int levelId) {
    if (!storage.isLevelUnlocked(levelId)) return;
    AudioService.to.playButtonClick();
    Get.toNamed('/game', arguments: {'levelId': levelId});
  }
}
