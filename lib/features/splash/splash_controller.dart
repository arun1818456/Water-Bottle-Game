import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_images.dart';
import '../../core/services/storage_service.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;
  bool _loadingStarted = false;

  /// Starts after SplashView has a BuildContext so Home assets can be decoded
  /// into Flutter's image cache before the route changes.
  void startLoading(BuildContext context) {
    if (_loadingStarted) return;
    _loadingStarted = true;
    _startLoadingSequence(context);
  }

  Future<void> _startLoadingSequence(BuildContext context) async {
    final homeAssets = Future.wait([
      precacheImage(const AssetImage(AppImages.backGround), context),
      precacheImage(const AssetImage(AppImages.appLogo), context),
    ]);

    for (var i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      progress.value = i / 100.0;
    }

    // Do not navigate until the Home background is ready to paint.
    await homeAssets;

    await Future.delayed(const Duration(milliseconds: 250));

    // Check if app is opened for the first time (tutorial not yet completed)
    final isFirstTime = !StorageService.to.tutorialCompleted.value;
    if (isFirstTime) {
      Get.offNamed('/tutorial');
    } else {
      Get.offNamed('/home');
    }
  }
}
