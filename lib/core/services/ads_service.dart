import 'dart:async';
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

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      return 'ca-app-pub-4886824424959094/2276252420'; //original
    } else if (Platform.isIOS) {
    }
    return '';
  }

  static String get gameBannerAdUnitId {
    if (Platform.isAndroid) {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      return 'ca-app-pub-4886824424959094/9522410959'; //original
    } else if (Platform.isIOS) {
    }
    return "";
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/1033173712';
      }
      return 'ca-app-pub-4886824424959094/7105907276'; //original
    } else if (Platform.isIOS) {
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/5224354917';
      }
      return 'ca-app-pub-4886824424959094/8315047168';//original
    } else if (Platform.isIOS) {
    }
    return '';
  }

  // State
  bool _isInitialized = false;
  BannerAd? _homeBannerAd;
  final RxBool isBannerLoaded = false.obs;
  bool _isHomeBannerLoading = false;
  int _homeBannerRetryAttempts = 0;

  BannerAd? _gameBannerAd;
  final RxBool isGameBannerLoaded = false.obs;
  bool _isGameBannerLoading = false;
  int _gameBannerRetryAttempts = 0;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _interstitialRetryAttempts = 0;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  int _rewardedRetryAttempts = 0;

  Future<AdsService> init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        // Completely unrestricted ad requests for 100% ad inventory and maximum fill rate in production
        final RequestConfiguration requestConfiguration = RequestConfiguration(
          ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
          maxAdContentRating: MaxAdContentRating.ma,
        );

        await MobileAds.instance.updateRequestConfiguration(
          requestConfiguration,
        );

        await MobileAds.instance.initialize();
        _isInitialized = true;
        loadHomeBanner();
        loadGameBanner();
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
    if (!_isInitialized || _isHomeBannerLoading || (isBannerLoaded.value && _homeBannerAd != null)) return;
    _isHomeBannerLoading = true;

    _homeBannerAd?.dispose();
    _homeBannerAd = null;
    isBannerLoaded.value = false;

    _homeBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Home Banner Ad loaded successfully.');
          isBannerLoaded.value = true;
          _isHomeBannerLoading = false;
          _homeBannerRetryAttempts = 0;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdsService: Home Banner Ad failed to load: ${error.message} (Code: ${error.code})');
          ad.dispose();
          _homeBannerAd = null;
          isBannerLoaded.value = false;
          _isHomeBannerLoading = false;
          _homeBannerRetryAttempts++;

          // Auto-retry with backoff (4s, 8s, 12s... max 30s)
          final delaySeconds = (_homeBannerRetryAttempts * 4).clamp(4, 30);
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (_isInitialized && !isBannerLoaded.value && !_isHomeBannerLoading) {
              loadHomeBanner();
            }
          });
        },
      ),
    );

    _homeBannerAd?.load();
  }

  Widget getHomeBannerWidget() {
    return Obx(() {
      if (isBannerLoaded.value && _homeBannerAd != null) {
        return Center(
          child: Container(
            width: _homeBannerAd!.size.width.toDouble(),
            height: _homeBannerAd!.size.height.toDouble(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: AdWidget(
              ad: _homeBannerAd!,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  // --- Banner Ad (Game View) ---

  void loadGameBanner() {
    if (!_isInitialized || _isGameBannerLoading || (isGameBannerLoaded.value && _gameBannerAd != null)) return;
    _isGameBannerLoading = true;

    _gameBannerAd?.dispose();
    _gameBannerAd = null;
    isGameBannerLoaded.value = false;

    _gameBannerAd = BannerAd(
      adUnitId: gameBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Game Banner Ad loaded successfully.');
          isGameBannerLoaded.value = true;
          _isGameBannerLoading = false;
          _gameBannerRetryAttempts = 0;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdsService: Game Banner Ad failed to load: ${error.message} (Code: ${error.code})');
          ad.dispose();
          _gameBannerAd = null;
          isGameBannerLoaded.value = false;
          _isGameBannerLoading = false;
          _gameBannerRetryAttempts++;

          // Auto-retry with backoff (4s, 8s, 12s... max 30s)
          final delaySeconds = (_gameBannerRetryAttempts * 4).clamp(4, 30);
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (_isInitialized && !isGameBannerLoaded.value && !_isGameBannerLoading) {
              loadGameBanner();
            }
          });
        },
      ),
    );

    _gameBannerAd?.load();
  }

  Widget getGameBannerWidget() {
    return Obx(() {
      if (isGameBannerLoaded.value && _gameBannerAd != null) {
        return Center(
          child: Container(
            width: _gameBannerAd!.size.width.toDouble(),
            height: _gameBannerAd!.size.height.toDouble(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: AdWidget(
              ad: _gameBannerAd!,
            ),
          ),
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
          debugPrint('AdsService: Interstitial pre-loaded successfully and ready in memory.');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialRetryAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _interstitialRetryAttempts++;

          // Exponential backoff auto-retry (max 30s) so an ad is always ready in advance
          final delaySeconds = (_interstitialRetryAttempts * 4).clamp(3, 30);
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (_interstitialAd == null && !_isInterstitialLoading) {
              _loadInterstitialAd();
            }
          });
        },
      ),
    );
  }

  /// Explicitly preloads interstitial ad in background
  void preloadInterstitialAd() {
    _loadInterstitialAd();
  }

  /// Checks if interstitial ad is currently cached and ready to show instantly
  bool get isInterstitialAdReady => _interstitialAd != null;

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
          // Immediately pre-load the next interstitial in advance
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
      // Background load without blocking user
      _loadInterstitialAd();
      onDismissed?.call();
    }
  }

  // --- Rewarded Ad (Hints, Undo, Double Coins, Free Coins) ---

  void _loadRewardedAd() {
    if (!_isInitialized || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Rewarded ad pre-loaded successfully and ready in memory.');
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedRetryAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
          _rewardedRetryAttempts++;

          // Exponential backoff auto-retry (max 30s) so an ad is always cached and ready on tap
          final delaySeconds = (_rewardedRetryAttempts * 3).clamp(3, 30);
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (_rewardedAd == null && !_isRewardedLoading) {
              _loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  /// Checks if rewarded ad is currently cached and ready to show instantly
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Preloads rewarded ad if not already loaded or loading
  void preloadRewardedAd() {
    _loadRewardedAd();
  }

  /// Shows rewarded ad with a callback on reward earned.
  /// If already pre-loaded (ideal state), shows instantly without delay.
  /// If not pre-loaded yet, shows a quick non-intrusive loading dialog and plays as soon as ready.
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd != null) {
      _displayCachedRewardedAd(
        onUserEarnedReward: onUserEarnedReward,
        onAdClosed: onAdClosed,
        onAdFailed: onAdFailed,
      );
    } else {
      debugPrint('AdsService: Rewarded ad not in memory, fetching with high priority...');

      // Show a sleek mini loader dialog so user gets immediate visual response instead of waiting/failing
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2448).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Opening Sponsor Ad...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      bool hasHandled = false;

      // Timeout safety: close loader after 4.5 seconds if network is extremely slow
      final timeoutTimer = Timer(const Duration(milliseconds: 4500), () {
        if (!hasHandled) {
          hasHandled = true;
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          onAdFailed?.call();
          Get.snackbar(
            'Connection Slow',
            'Network is taking longer than usual. Please check internet connection and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF143767),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      });

      _isRewardedLoading = true;
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoading = false;
            _rewardedRetryAttempts = 0;

            if (!hasHandled) {
              hasHandled = true;
              timeoutTimer.cancel();
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }
              _displayCachedRewardedAd(
                onUserEarnedReward: onUserEarnedReward,
                onAdClosed: onAdClosed,
                onAdFailed: onAdFailed,
              );
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdsService: Fallback Rewarded load failed: $error');
            _rewardedAd = null;
            _isRewardedLoading = false;

            if (!hasHandled) {
              hasHandled = true;
              timeoutTimer.cancel();
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }
              onAdFailed?.call();
            }
          },
        ),
      );
    }
  }

  void _displayCachedRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd == null) {
      onAdFailed?.call();
      return;
    }

    final adToShow = _rewardedAd!;
    _rewardedAd = null; // Clear immediately to prevent double presentation

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        // Pre-load the next rewarded ad right away so the user never has to wait next time
        _loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsService: Rewarded ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
        onAdFailed?.call();
      },
    );

    adToShow.show(onUserEarnedReward: (adWithoutView, reward) {
      onUserEarnedReward(reward);
    });
  }

  @override
  void onClose() {
    _homeBannerAd?.dispose();
    _gameBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
