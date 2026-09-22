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
  AudioPlayer? _pourPlayer;

  bool _isMusicPlaying = false;
  bool _isMusicPaused = false;
  bool _isAppInForeground = true;
  Worker? _musicSettingWorker;

  Future<AudioService> init() async {
    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      _pourPlayer = AudioPlayer();

      // Configure background music loop and keep it low so short SFX
      // can still play without silencing the ambient track.
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer?.setVolume(0.08);

      await _sfxPlayer?.setVolume(0.72);
      await _pourPlayer?.setVolume(0.76);

      // Listen to changes in storage settings
      WidgetsBinding.instance.addObserver(this);
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
      if (_musicPlayer == null || _isMusicPlaying) return;

      if (_isMusicPaused) {
        await _musicPlayer!.resume();
      } else {
        await _musicPlayer!.play(AssetSource(AssetsConstants.audioAmbient));
      }
      _isMusicPaused = false;
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('AudioService: Failed to play ambient music: $e');
    }
  }

  /// Pauses rather than stops so a returning player hears the same loop position.
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_isMusicPlaying && _musicPlayer != null) {
        await _musicPlayer!.pause();
        _isMusicPlaying = false;
        _isMusicPaused = true;
      }
    } catch (e) {
      debugPrint('AudioService: Failed to pause ambient music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if ((_isMusicPlaying || _isMusicPaused) && _musicPlayer != null) {
        await _musicPlayer!.stop();
        _isMusicPlaying = false;
        _isMusicPaused = false;
      }
    } catch (e) {
      debugPrint('AudioService: Failed to stop ambient music: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        startBackgroundMusic();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isAppInForeground = false;
        pauseBackgroundMusic();
        break;
      case AppLifecycleState.detached:
        _isAppInForeground = false;
        stopBackgroundMusic();
        break;
    }
  }

  Future<void> playButtonClick() async {
    if (!StorageService.to.soundEnabled.value) return;
    try {
      if (_sfxPlayer != null) {
        await _sfxPlayer!.play(AssetSource(AssetsConstants.audioClick));
      }
    } catch (e) {
      debugPrint('AudioService: Button click error: $e');
    }
  }

  Future<void> playPourSound() async {
    if (!StorageService.to.soundEnabled.value) return;
    try {
      if (_pourPlayer != null) {
        await _pourPlayer!.play(AssetSource(AssetsConstants.audioPour));
      }
    } catch (e) {
      debugPrint('AudioService: Pour sound error: $e');
    }
  }

  Future<void> playWinSound() async {
    if (!StorageService.to.soundEnabled.value) return;
    try {
      if (_sfxPlayer != null) {
        await _sfxPlayer!.play(AssetSource(AssetsConstants.audioWin));
      }
    } catch (e) {
      debugPrint('AudioService: Win sound error: $e');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _musicSettingWorker?.dispose();
    _musicPlayer?.dispose();
    _sfxPlayer?.dispose();
    _pourPlayer?.dispose();
    super.onClose();
  }
}
