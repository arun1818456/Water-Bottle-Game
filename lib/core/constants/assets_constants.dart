/// Asset file paths
class AssetsConstants {
  AssetsConstants._();

  // Audio paths
  static const String audioClick = 'audio/click.wav';
  static const String audioPour = 'audio/pour.wav';
  static const String audioWin = 'audio/win.wav';
  static const String audioAmbient = 'audio/ambient.wav';

  // Lottie animations
  static const String lottieCelebration = 'assets/lottie/win_celebration.json';

  // Level file path generator
  static String getLevelPath(int levelId) {
    final padded = levelId.toString().padLeft(3, '0');
    return 'assets/levels/level_$padded.json';
  }
}
