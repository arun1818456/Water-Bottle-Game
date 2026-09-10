import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../constants/assets_constants.dart';
import 'storage_service.dart';

/// AudioService manages background music and sound effects using audioplayers.
class AudioService extends GetxService {
  static AudioService get to => Get.find<AudioService>();

  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _pourPlayer;

  bool _isMusicPlaying = false;

  Future<AudioService> init() async {
    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      _pourPlayer = AudioPlayer();

      // Configure background music loop
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer?.setVolume(0.35);

      await _sfxPlayer?.setVolume(0.85);
      await _pourPlayer?.setVolume(0.8);

      // Listen to changes in storage settings
      ever(StorageService.to.musicEnabled, (bool enabled) {
        if (enabled) {
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
    if (!StorageService.to.musicEnabled.value) return;
    try {
      if (!_isMusicPlaying && _musicPlayer != null) {
        await _musicPlayer!.play(AssetSource(AssetsConstants.audioAmbient));
        _isMusicPlaying = true;
      }
    } catch (e) {
      debugPrint('AudioService: Failed to play ambient music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if (_isMusicPlaying && _musicPlayer != null) {
        await _musicPlayer!.stop();
        _isMusicPlaying = false;
      }
    } catch (e) {
      debugPrint('AudioService: Failed to stop ambient music: $e');
    }
  }

  Future<void> playButtonClick() async {
    if (!StorageService.to.soundEnabled.value) return;
    try {
      if (_sfxPlayer != null) {
        await _sfxPlayer!.stop();
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
        await _pourPlayer!.stop();
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
        await _sfxPlayer!.stop();
        await _sfxPlayer!.play(AssetSource(AssetsConstants.audioWin));
      }
    } catch (e) {
      debugPrint('AudioService: Win sound error: $e');
    }
  }

  @override
  void onClose() {
    _musicPlayer?.dispose();
    _sfxPlayer?.dispose();
    _pourPlayer?.dispose();
    super.onClose();
  }
}
