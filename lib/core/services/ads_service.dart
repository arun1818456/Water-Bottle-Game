import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import '../widgets/internet_required_dialog.dart';
import 'storage_service.dart';

/// Reusable Google Mobile Ads service managing Banners, Interstitials, and Rewarded ads.
/// Debug builds use Google's official test ad unit IDs; release builds use production IDs.
class AdsService extends GetxService {
  static AdsService get to => Get.find<AdsService>();

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      return 'ca-app-pub-4886824424959094/2276252420'; //original
    }
    // iOS: no production unit configured yet
    return '';
  }

  static String get gameBannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      return 'ca-app-pub-4886824424959094/9522410959'; //original
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/1033173712';
      }
      return 'ca-app-pub-4886824424959094/7105907276'; //original
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/5224354917';
      }
      return 'ca-app-pub-4886824424959094/8315047168'; //original
    }
    return '';
  }

  // --- Tuning ---

  /// Full-screen ads expire on Google's side after ~1 hour; drop cached ones a bit earlier.
  static const Duration _fullScreenAdMaxAge = Duration(minutes: 50);

  /// After this many consecutive failures, background retries pause until the next
  /// explicit request (screen open, preload call) instead of hammering AdMob forever.
  static const int _maxAutoRetries = 5;

  /// Minimum gap between an interstitial and any previous full-screen ad.
  static const Duration _minInterstitialGap = Duration(seconds: 30);

  /// How long the "Opening Sponsor Ad..." loader waits for an on-demand rewarded ad.
  static const Duration _rewardedOnDemandTimeout = Duration(seconds: 4);

  // --- State ---
  bool _isInitialized = false;

  DateTime? _lastConnectivityCheck;
  bool _lastConnectivityResult = true;

  /// Fast connectivity check with 1200ms timeout.
  /// Results are cached for 3 seconds to avoid duplicate DNS lookups on rapid taps.
  Future<bool> checkInternetConnection({bool force = false}) async {
    if (kIsWeb) return true;
    final now = DateTime.now();
    if (!force &&
        _lastConnectivityCheck != null &&
        now.difference(_lastConnectivityCheck!) < const Duration(seconds: 3)) {
      return _lastConnectivityResult;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 1200));
      _lastConnectivityResult =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _lastConnectivityResult = false;
    } on TimeoutException catch (_) {
      _lastConnectivityResult = false;
    } catch (_) {
      _lastConnectivityResult = false;
    }

    _lastConnectivityCheck = DateTime.now();
    return _lastConnectivityResult;
  }

  final _BannerSlotState _homeBanner = _BannerSlotState('Home');
  final _BannerSlotState _gameBanner = _BannerSlotState('Game');

  /// Kept for backwards compatibility with existing listeners.
  RxBool get isBannerLoaded => _homeBanner.isLoaded;
  RxBool get isGameBannerLoaded => _gameBanner.isLoaded;

  InterstitialAd? _interstitialAd;
  DateTime? _interstitialLoadedAt;
  bool _isInterstitialLoading = false;
  int _interstitialRetryAttempts = 0;

  RewardedAd? _rewardedAd;
  DateTime? _rewardedLoadedAt;
  bool _isRewardedLoading = false;
  int _rewardedRetryAttempts = 0;

  /// Callbacks waiting for the in-flight rewarded load (on-demand path joins it
  /// instead of firing a second parallel request that would overwrite the first).
  final List<void Function(bool loaded)> _rewardedLoadWaiters = [];

  /// True while any full-screen ad (interstitial or rewarded) is on screen.
  bool _isShowingFullScreenAd = false;
  DateTime? _lastFullScreenAdClosedAt;

  /// Whether a full-screen ad is currently being presented.
  bool get isShowingFullScreenAd => _isShowingFullScreenAd;

  Future<AdsService> init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Don't block app startup on the SDK handshake (it can take seconds on slow networks).
      unawaited(_initializeSdk());
    }
    return this;
  }

  Future<void> _initializeSdk() async {
    try {
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
        maxAdContentRating: MaxAdContentRating.ma,
      );
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
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

  static Duration _retryDelay(int attempts) =>
      Duration(seconds: (attempts * 4).clamp(4, 30));

  // ---------------------------------------------------------------------------
  // Banners
  // ---------------------------------------------------------------------------

  void loadHomeBanner() => _loadBanner(_homeBanner, bannerAdUnitId);

  void loadGameBanner() => _loadBanner(_gameBanner, gameBannerAdUnitId);

  void _loadBanner(_BannerSlotState slot, String adUnitId) {
    if (!_isInitialized || adUnitId.isEmpty) return;
    if (slot.isLoading || (slot.isLoaded.value && slot.ad != null)) return;
    // Respect backoff: views call this from build(), which must not trigger a request storm.
    final next = slot.nextAttemptAt;
    if (next != null && DateTime.now().isBefore(next)) return;

    slot.isLoading = true;
    slot.ad?.dispose();
    slot.ad = null;
    slot.isLoaded.value = false;

    final banner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdsService: ${slot.name} Banner loaded.');
          slot.ad = ad as BannerAd;
          slot.isLoading = false;
          slot.retryAttempts = 0;
          slot.nextAttemptAt = null;
          slot.isLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdsService: ${slot.name} Banner failed: ${error.message} (Code: ${error.code})');
          ad.dispose();
          if (identical(slot.ad, ad)) slot.ad = null;
          slot.isLoaded.value = false;
          slot.isLoading = false;
          slot.retryAttempts++;

          final delay = _retryDelay(slot.retryAttempts);
          slot.nextAttemptAt = DateTime.now().add(delay);
          if (slot.retryAttempts <= _maxAutoRetries) {
            Future.delayed(delay, () => _loadBanner(slot, adUnitId));
          }
        },
      ),
    );
    slot.ad = banner;
    banner.load();
  }

  Widget getHomeBannerWidget() => _BannerAdSlot(slot: _homeBanner);

  Widget getGameBannerWidget() => _BannerAdSlot(slot: _gameBanner);

  // ---------------------------------------------------------------------------
  // Interstitial
  // ---------------------------------------------------------------------------

  void _loadInterstitialAd() {
    if (!_isInitialized || _isInterstitialLoading || interstitialAdUnitId.isEmpty) return;
    if (_interstitialAd != null) {
      if (!_isExpired(_interstitialLoadedAt)) return;
      debugPrint('AdsService: Cached interstitial expired, reloading.');
      _interstitialAd!.dispose();
      _interstitialAd = null;
    }
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Interstitial pre-loaded.');
          _interstitialAd = ad;
          _interstitialLoadedAt = DateTime.now();
          _isInterstitialLoading = false;
          _interstitialRetryAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _interstitialRetryAttempts++;
          if (_interstitialRetryAttempts <= _maxAutoRetries) {
            Future.delayed(_retryDelay(_interstitialRetryAttempts), () {
              if (_interstitialAd == null && !_isInterstitialLoading) {
                _loadInterstitialAd();
              }
            });
          }
        },
      ),
    );
  }

  /// Explicitly preloads interstitial ad in background
  void preloadInterstitialAd() {
    if (_interstitialAd == null && !_isInterstitialLoading) {
      _interstitialRetryAttempts = 0; // explicit request re-arms paused retries
    }
    _loadInterstitialAd();
  }

  /// Checks if interstitial ad is currently cached and ready to show instantly
  bool get isInterstitialAdReady => _interstitialAd != null && !_isExpired(_interstitialLoadedAt);

  /// Shows an interstitial every [AppConstants.interstitialLevelInterval] completed levels.
  /// [onComplete] always runs exactly once (after the ad, or immediately if none is shown).
  void showInterstitialIfEligible({VoidCallback? onComplete, bool isTutorial = false}) async {
    final completed = StorageService.to.completedCount.value;
    final lastClosed = _lastFullScreenAdClosedAt;
    final tooSoon = lastClosed != null &&
        DateTime.now().difference(lastClosed) < _minInterstitialGap;

    if (!isTutorial &&
        !tooSoon &&
        completed > 0 &&
        completed % AppConstants.interstitialLevelInterval == 0) {
      // If internet is off or ad is not ready, skip ad immediately so next level comes instantly
      final hasInternet = await checkInternetConnection();
      if (!hasInternet || !isInterstitialAdReady) {
        debugPrint('AdsService: Offline or interstitial not ready, continuing level progression directly.');
        onComplete?.call();
        return;
      }
      showInterstitialAd(onDismissed: onComplete);
    } else {
      onComplete?.call();
    }
  }

  void showInterstitialAd({VoidCallback? onDismissed}) {
    var done = false;
    Timer? safetyTimer;

    void finish() {
      if (done) return;
      done = true;
      safetyTimer?.cancel();
      onDismissed?.call();
    }

    if (_isShowingFullScreenAd || !isInterstitialAdReady) {
      preloadInterstitialAd();
      finish();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null; // prevent double presentation
    _isShowingFullScreenAd = true;

    // Safety failsafe: if AdMob SDK fails to fire any dismissal or failure callback
    // within 2 seconds of presentation, guarantee level completion progression.
    safetyTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!done) {
        debugPrint('AdsService: Interstitial presentation timeout failsafe triggered.');
        _isShowingFullScreenAd = false;
        finish();
      }
    });

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _onFullScreenAdClosed();
        _loadInterstitialAd();
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsService: Interstitial failed to show: $error');
        ad.dispose();
        _isShowingFullScreenAd = false;
        _loadInterstitialAd();
        finish();
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('AdsService: Error presenting interstitial ad: $e');
      _isShowingFullScreenAd = false;
      finish();
    }
  }

  // ---------------------------------------------------------------------------
  // Rewarded (Hints, Extra Bottle, Double Coins, Free Coins)
  // ---------------------------------------------------------------------------

  void _loadRewardedAd() {
    if (!_isInitialized || _isRewardedLoading || rewardedAdUnitId.isEmpty) return;
    if (_rewardedAd != null) {
      if (!_isExpired(_rewardedLoadedAt)) return;
      debugPrint('AdsService: Cached rewarded ad expired, reloading.');
      _rewardedAd!.dispose();
      _rewardedAd = null;
    }
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsService: Rewarded ad pre-loaded.');
          _rewardedAd = ad;
          _rewardedLoadedAt = DateTime.now();
          _isRewardedLoading = false;
          _rewardedRetryAttempts = 0;
          _notifyRewardedWaiters(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
          _rewardedRetryAttempts++;
          _notifyRewardedWaiters(false);
          if (_rewardedRetryAttempts <= _maxAutoRetries) {
            Future.delayed(_retryDelay(_rewardedRetryAttempts), () {
              if (_rewardedAd == null && !_isRewardedLoading) {
                _loadRewardedAd();
              }
            });
          }
        },
      ),
    );
  }

  void _notifyRewardedWaiters(bool loaded) {
    if (_rewardedLoadWaiters.isEmpty) return;
    final waiters = List.of(_rewardedLoadWaiters);
    _rewardedLoadWaiters.clear();
    for (final w in waiters) {
      w(loaded);
    }
  }

  /// Checks if rewarded ad is currently cached and ready to show instantly
  bool get isRewardedAdReady => _rewardedAd != null && !_isExpired(_rewardedLoadedAt);

  /// Preloads rewarded ad if not already loaded or loading
  void preloadRewardedAd() {
    if (_rewardedAd == null && !_isRewardedLoading) {
      _rewardedRetryAttempts = 0; // explicit request re-arms paused retries
    }
    _loadRewardedAd();
  }

  /// Shows a rewarded ad. If one is cached it plays instantly; otherwise a small
  /// loader is shown while one is fetched. Exactly one of [onAdClosed] / [onAdFailed]
  /// is called once the flow ends, so callers can always reset their busy state.
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
    String? customOfflineMessage,
  }) async {
    var finished = false;
    void fail({bool notify = true}) {
      if (finished) return;
      finished = true;
      if (notify) _showAdUnavailableMessage();
      onAdFailed?.call();
    }

    if (_isShowingFullScreenAd) {
      fail(notify: false);
      return;
    }

    // Instant offline check: Never show the blocking loader if offline
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) {
      fail(notify: false);
      InternetRequiredDialog.show(
        title: 'Internet Required',
        message: customOfflineMessage ??
            'An internet connection is required to watch the ad. Please connect to the internet and try again.',
      );
      return;
    }

    if (!_isInitialized || rewardedAdUnitId.isEmpty) {
      fail();
      return;
    }

    void present() {
      if (finished) return;
      finished = true;
      _displayCachedRewardedAd(
        onUserEarnedReward: onUserEarnedReward,
        onAdClosed: onAdClosed,
        onAdFailed: onAdFailed,
      );
    }

    if (isRewardedAdReady) {
      present();
      return;
    }

    debugPrint('AdsService: Rewarded ad not cached, fetching on demand...');
    final closeLoader = _showAdLoader();

    late final Timer timeoutTimer;
    void onLoadResult(bool loaded) {
      if (finished) return; // timed out already; the ad stays cached for next tap
      timeoutTimer.cancel();
      closeLoader();
      if (loaded && isRewardedAdReady) {
        present();
      } else {
        fail();
      }
    }

    timeoutTimer = Timer(_rewardedOnDemandTimeout, () {
      _rewardedLoadWaiters.remove(onLoadResult);
      closeLoader();
      fail();
    });

    _rewardedLoadWaiters.add(onLoadResult);
    _rewardedRetryAttempts = 0;
    _loadRewardedAd(); // no-op if a load is already in flight; we join it via the waiter
    if (!_isRewardedLoading && !isRewardedAdReady) {
      // Load could not even start (e.g. unit ID missing)
      _rewardedLoadWaiters.remove(onLoadResult);
      onLoadResult(false);
    }
  }

  void _displayCachedRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    final adToShow = _rewardedAd;
    if (adToShow == null) {
      _showAdUnavailableMessage();
      onAdFailed?.call();
      return;
    }
    _rewardedAd = null; // Clear immediately to prevent double presentation
    _isShowingFullScreenAd = true;

    var rewarded = false;
    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _onFullScreenAdClosed();
        _loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsService: Rewarded ad failed to show: $error');
        ad.dispose();
        _isShowingFullScreenAd = false;
        _loadRewardedAd();
        _showAdUnavailableMessage();
        onAdFailed?.call();
      },
    );

    try {
      adToShow.show(onUserEarnedReward: (adWithoutView, reward) {
        if (rewarded) return; // guard against duplicate SDK callbacks
        rewarded = true;
        onUserEarnedReward(reward);
      });
    } catch (e) {
      debugPrint('AdsService: Error showing rewarded ad: $e');
      _isShowingFullScreenAd = false;
      _showAdUnavailableMessage();
      onAdFailed?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isExpired(DateTime? loadedAt) =>
      loadedAt == null || DateTime.now().difference(loadedAt) > _fullScreenAdMaxAge;

  void _onFullScreenAdClosed() {
    _isShowingFullScreenAd = false;
    _lastFullScreenAdClosedAt = DateTime.now();
  }

  void _showAdUnavailableMessage() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Ad Not Available',
      'No ad is ready right now. Please check your internet connection and try again shortly.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF143767),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows the loader and returns a function that closes exactly that dialog.
  VoidCallback _showAdLoader() {
    final navigator = Get.key.currentState;
    final context = Get.overlayContext ?? Get.context;
    if (navigator == null || context == null) return () {};

    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => const PopScope(
        canPop: true,
        child: _AdLoaderDialog(),
      ),
    );
    navigator.push(route);

    var closed = false;
    return () {
      if (closed) return;
      closed = true;
      try {
        if (route.isActive) {
          navigator.removeRoute(route);
        }
      } catch (e) {
        debugPrint('AdsService: Safe route removal notice: $e');
      }
    };
  }

  @override
  void onClose() {
    _homeBanner.ad?.dispose();
    _gameBanner.ad?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}

/// Mutable state for one banner placement.
class _BannerSlotState {
  _BannerSlotState(this.name);

  final String name;
  BannerAd? ad;
  final RxBool isLoaded = false.obs;
  bool isLoading = false;
  int retryAttempts = 0;
  DateTime? nextAttemptAt;

  /// The mounted [_BannerAdSlot] currently allowed to render the AdWidget.
  /// A BannerAd may only be in the widget tree once; during route transitions two
  /// screens can briefly coexist, which otherwise throws "AdWidget is already in the Widget tree".
  final Rxn<Object> owner = Rxn<Object>();
}

class _BannerAdSlot extends StatefulWidget {
  const _BannerAdSlot({required this.slot});

  final _BannerSlotState slot;

  @override
  State<_BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<_BannerAdSlot> {
  final Object _token = Object();

  @override
  void initState() {
    super.initState();
    widget.slot.owner.value ??= _token;
  }

  @override
  void dispose() {
    final slot = widget.slot;
    if (slot.owner.value == _token) {
      // Defer: changing an Rx during unmount would rebuild another widget while the tree is locked.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (slot.owner.value == _token) slot.owner.value = null;
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    return Obx(() {
      final owner = slot.owner.value;
      final loaded = slot.isLoaded.value;
      final ad = slot.ad;

      if (owner == null) {
        // Previous owner went away; claim the banner after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) slot.owner.value ??= _token;
        });
        return const SizedBox.shrink();
      }
      if (owner != _token || !loaded || ad == null) {
        return const SizedBox.shrink();
      }

      return Center(
        child: Container(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          // Key by ad instance so a reloaded banner gets a fresh AdWidget.
          child: AdWidget(key: ObjectKey(ad), ad: ad),
        ),
      );
    });
  }
}

class _AdLoaderDialog extends StatelessWidget {
  const _AdLoaderDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Opening Sponsor Ad...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
