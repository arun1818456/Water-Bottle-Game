import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Reusable Google Mobile Ads service managing Banners, Interstitials, and Rewarded ads.
/// Configured with official Google test ad unit IDs. Replace with your production IDs before store submission.
class AdsService extends GetxService {
  static AdsService get to => Get.find<AdsService>();

  // ===========================================================================
  // AD UNIT IDs (Configured with official test IDs)
  // Replace these with your production AdMob ad unit IDs before release!
  // ===========================================================================

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Android Test Banner ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS Test Banner ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      // return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Android Test Interstitial ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // iOS Test Interstitial ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      // return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Android Test Rewarded ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      // iOS Test Rewarded ID
      // PRODUCTION: Replace with "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
      // return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  // State
  bool _isInitialized = false;
  BannerAd? _homeBannerAd;
  final RxBool isBannerLoaded = false.obs;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  Future<AdsService> init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await MobileAds.instance.initialize();
        _isInitialized = true;
        loadHomeBanner();
        _loadInterstitialAd();
        _loadRewardedAd();
      } catch (e) {
        debugPrint('AdsService: Initialization failed: $e');
      }
    }
    return this;
  }

  // --- Banner Ad (Home Screen Only) ---

  void loadHomeBanner() {
    if (!_isInitialized || isBannerLoaded.value) return;

    _homeBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Banner Ad loaded.');
          isBannerLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdsService: Banner Ad failed to load: $error');
          ad.dispose();
          _homeBannerAd = null;
          isBannerLoaded.value = false;
        },
      ),
    );

    _homeBannerAd?.load();
  }

  Widget getHomeBannerWidget() {
    return Obx(() {
      if (isBannerLoaded.value && _homeBannerAd != null) {
        return SizedBox(
          width: _homeBannerAd!.size.width.toDouble(),
          height: _homeBannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _homeBannerAd!),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // --- Interstitial Ad (Every 4 Completed Levels) ---

  void _loadInterstitialAd() {
    if (!_isInitialized || _isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Interstitial loaded.');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Checks if an interstitial ad should be shown based on completed levels
  void showInterstitialIfEligible({VoidCallback? onComplete}) {
    final completed = StorageService.to.completedCount.value;
    if (completed > 0 && completed % AppConstants.interstitialLevelInterval == 0) {
      showInterstitialAd(onDismissed: onComplete);
    } else {
      onComplete?.call();
    }
  }

  void showInterstitialAd({VoidCallback? onDismissed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('AdsService: Interstitial failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd();
      onDismissed?.call();
    }
  }

  // --- Rewarded Ad (Hints, Undo, Double Coins) ---

  void _loadRewardedAd() {
    if (!_isInitialized || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Rewarded ad loaded.');
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows rewarded ad with a callback on reward earned
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('AdsService: Rewarded ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdFailed?.call();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (adWithoutView, reward) {
        onUserEarnedReward(reward);
      });
    } else {
      // In development or when ad is not available, reward the user anyway or handle gracefully
      debugPrint('AdsService: Rewarded ad not ready, providing fallback reward.');
      _loadRewardedAd();
      onUserEarnedReward(RewardItem(50, 'Coins'));
      onAdClosed?.call();
    }
  }

  @override
  void onClose() {
    _homeBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
