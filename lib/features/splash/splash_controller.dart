import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startLoadingSequence();
  }

  Future<void> _startLoadingSequence() async {
    for (var i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      progress.value = i / 100.0;
    }

    await Future.delayed(const Duration(milliseconds: 250));
    Get.offNamed('/home');
  }
}
