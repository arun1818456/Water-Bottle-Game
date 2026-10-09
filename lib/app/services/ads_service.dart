import 'package:water_bottle_ais/exports.dart';

/// Reusable Google Mobile Ads service managing Banners, Interstitials, and Rewarded ads.
class AdsService extends GetxService {
  static AdsService get to => Get.find<AdsService>();

  static String get bannerAdUnitId {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get rewardedAdUnitId {
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  final RxBool isBannerLoaded = false.obs;

  Future<AdsService> init() async {
    return this;
  }
}
