import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../constants/assets_constants.dart';
import 'storage_service.dart';

/// AudioService manages background music and sound effects using audioplayers.
class AudioService extends GetxService with WidgetsBindingObserver {
  static AudioService get to => Get.find<AudioService>();

  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _bottleTapPlayer;
  AudioPlayer? _pourPlayer;
  AudioPlayer? _winPlayer;

  bool _isAppInForeground = true;
  Worker? _musicSettingWorker;
  AppLifecycleListener? _lifecycleListener;
  Timer? _recoveryTimer;

  Future<AudioService> init() async {
    try {
      // 1. Configure global audio context so SFX never interrupts or pauses BGM.
      // Setting audioFocus to none tells Android AudioManager not to steal focus or pause background music when SFX plays.
      final AudioContext audioContext = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {},
        ),
      );
      await AudioPlayer.global.setAudioContext(audioContext);

      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      _bottleTapPlayer = AudioPlayer();
      _pourPlayer = AudioPlayer();
      _winPlayer = AudioPlayer();

      // Configure background music loop and reduce volumes as requested
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer?.setVolume(0.05); // Reduced ambient BGM volume

      // Reduced SFX volumes for pleasant and balanced audio
      await _sfxPlayer?.setVolume(0.35);
      await _bottleTapPlayer?.setVolume(0.40);
      await _pourPlayer?.setVolume(0.40);
      await _winPlayer?.setVolume(0.45);

      // Listen to player state to track playing status and auto-recover if interrupted
      _musicPlayer?.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          // Auto-recover ambient music if interrupted while in foreground and enabled
          if (_isAppInForeground && StorageService.to.musicEnabled.value) {
            _recoveryTimer?.cancel();
            _recoveryTimer = Timer(const Duration(milliseconds: 300), () {
              if (_isAppInForeground &&
                  StorageService.to.musicEnabled.value &&
                  _musicPlayer?.state != PlayerState.playing) {
                resumeBackgroundMusic();
              }
            });
          }
        }
      });

      // AppLifecycleListener provides immediate lifecycle callbacks
      _lifecycleListener = AppLifecycleListener(
        onPause: pauseAllAudio,
        onInactive: pauseAllAudio,
        onHide: pauseAllAudio,
        onDetach: pauseAllAudio,
        onResume: resumeBackgroundMusic,
      );

      // Also listen via WidgetsBindingObserver for maximum device compatibility
      WidgetsBinding.instance.addObserver(this);

      // Listen to changes in storage settings
      _musicSettingWorker = ever(StorageService.to.musicEnabled, (bool enabled) {
        if (enabled && _isAppInForeground) {
          startBackgroundMusic();
        } else {
          stopBackgroundMusic();
        }
      });

      if (StorageService.to.musicEnabled.value) {
        startBackgroundMusic();
      }
    } catch (e) {
      debugPrint('AudioService: Platform audio unavailable (e.g. in tests): $e');
    }

    return this;
  }

  Future<void> startBackgroundMusic() async {
    if (!StorageService.to.musicEnabled.value || !_isAppInForeground) return;
    try {
      if (_musicPlayer == null) return;
      if (_musicPlayer!.state == PlayerState.playing) {
        return;
      }

      if (_musicPlayer!.state == PlayerState.paused) {
        await _musicPlayer!.resume();
      } else {
        await _musicPlayer!.play(AssetSource(AssetsConstants.audioAmbient));
      }
    } catch (e) {
      debugPrint('AudioService: Failed to play ambient music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    _isAppInForeground = true;
    if (!StorageService.to.musicEnabled.value) return;
    try {
      if (_musicPlayer == null) return;
      if (_musicPlayer!.state == PlayerState.paused) {
        await _musicPlayer!.resume();
      } else if (_musicPlayer!.state != PlayerState.playing) {
        await _musicPlayer!.play(AssetSource(AssetsConstants.audioAmbient));
      }
    } catch (e) {
      debugPrint('AudioService: Failed to resume ambient music: $e');
      try {
        await _musicPlayer?.play(AssetSource(AssetsConstants.audioAmbient));
      } catch (_) {}
    }
  }

  /// Pauses ambient music
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.pause();
      }
    } catch (e) {
      debugPrint('AudioService: Failed to pause ambient music: $e');
    }
  }

  /// Unconditionally stops/pauses all audio (music + SFX) when app is minimized or put in recents
  Future<void> pauseAllAudio() async {
    _isAppInForeground = false;
    _recoveryTimer?.cancel();
    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.pause();
      }
      await _sfxPlayer?.stop();
      await _bottleTapPlayer?.stop();
      await _pourPlayer?.stop();
      await _winPlayer?.stop();
    } catch (e) {
      debugPrint('AudioService: Failed to pause all audio: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    _recoveryTimer?.cancel();
    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.stop();
      }
    } catch (e) {
      debugPrint('AudioService: Failed to stop ambient music: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resumeBackgroundMusic();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        pauseAllAudio();
        break;
    }
  }

  Future<void> playButtonClick() async {
    if (!StorageService.to.soundEnabled.value || !_isAppInForeground) return;
    try {
      if (_sfxPlayer != null) {
        await _sfxPlayer!.play(AssetSource(AssetsConstants.audioClick));
      }
    } catch (e) {
      debugPrint('AudioService: Button click error: $e');
    }
  }

  /// Plays crystal glass clink sound when tapping a bottle
  Future<void> playBottleTapSound() async {
    if (!StorageService.to.soundEnabled.value || !_isAppInForeground) return;
    try {
      if (_bottleTapPlayer != null) {
        await _bottleTapPlayer!.play(AssetSource(AssetsConstants.audioBottleTap));
      }
    } catch (e) {
      debugPrint('AudioService: Bottle tap error: $e');
    }
  }

  Future<void> playPourSound() async {
    if (!StorageService.to.soundEnabled.value || !_isAppInForeground) return;
    try {
      if (_pourPlayer != null) {
        await _pourPlayer!.play(AssetSource(AssetsConstants.audioPour));
      }
    } catch (e) {
      debugPrint('AudioService: Pour sound error: $e');
    }
  }

  Future<void> playWinSound() async {
    if (!StorageService.to.soundEnabled.value || !_isAppInForeground) return;
    try {
      if (_winPlayer != null) {
        await _winPlayer!.play(AssetSource(AssetsConstants.audioWin));
      }
    } catch (e) {
      debugPrint('AudioService: Win sound error: $e');
    }
  }

  @override
  void onClose() {
    _recoveryTimer?.cancel();
    _lifecycleListener?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _musicSettingWorker?.dispose();
    _musicPlayer?.dispose();
    _sfxPlayer?.dispose();
    _bottleTapPlayer?.dispose();
    _pourPlayer?.dispose();
    _winPlayer?.dispose();
    super.onClose();
  }
}
