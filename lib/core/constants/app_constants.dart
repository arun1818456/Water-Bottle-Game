/// Application constants and game balance values
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'Aqua Sort Master';
  static const String appVersion = '1.0.0';

  // Game Rules
  static const int maxBottleCapacity = 4;
  static const int totalHandcraftedLevels = 120;

  // Economy & Rewards
  static const int coinsPerLevelClear = 25;
  static const int coinsFor3Stars = 15;
  static const int coinsFor2Stars = 10;
  static const int coinsFor1Star = 5;
  static const int rewardedAdCoins = 50;

  // Daily Rewards by Day (1 to 7)
  static const List<int> dailyRewards = [50, 75, 100, 150, 200, 300, 500];

  // Ad triggers
  static const int interstitialLevelInterval = 2; // Every 4 completed levels

  // Star scoring rules:
  // 3 stars = 0 undos used
  // 2 stars = <= 2 undos or 1 hint used
  // 1 star = completed with multiple assists
}

/// Bottle Skins available in Shop
enum BottleSkinType {
  glass('Glass Bottle', 0, 'Sleek transparent glass with subtle reflection'),
  neon('Neon Bottle', 200, 'Luminescent glowing border with cyberpunk vibe'),
  crystal('Crystal Bottle', 350, 'Faceted geometric cuts reflecting brilliant light'),
  gold('Gold Bottle', 500, 'Luxurious 24K gilded rim and golden luster'),
  dark('Dark Bottle', 750, 'Smoked obsidian glass with mystic dark aura');

  final String title;
  final int price;
  final String description;

  const BottleSkinType(this.title, this.price, this.description);
}

/// Background Themes available in Shop
enum BackgroundThemeType {
  ocean('Ocean Deep', 0, 'Deep azure abyss with calming gradients'),
  sunset('Sunset Horizon', 200, 'Warm tropical purple and coral sunset'),
  space('Space Nebula', 350, 'Cosmic deep indigo with twinkling star dust'),
  forest('Mystic Forest', 500, 'Lush emerald and teal woodland midnight');

  final String title;
  final int price;
  final String description;

  const BackgroundThemeType(this.title, this.price, this.description);
}
