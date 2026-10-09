import 'dart:convert';
import 'package:water_bottle_ais/exports.dart';

/// LevelManager handles loading of handcrafted JSON levels and procedural fallback
class LevelManager {
  LevelManager._();

  static final Map<int, List<Bottle>> _levelCache = {};

  static Future<List<Bottle>> loadLevel(int levelId) async {
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId]!.map((b) => b.clone()).toList();
    }

    if (levelId <= AppConstants.totalHandcraftedLevels) {
      try {
        final path = AssetsConstants.getLevelPath(levelId);
        final jsonString = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final levelData = LevelData.fromJson(jsonMap);
        final bottleList = levelData.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
        _levelCache[levelId] = bottleList;
        return bottleList.map((b) => b.clone()).toList();
      } catch (e) {
        final proceduralData = ProceduralLevelGenerator.generateLevel(levelId: levelId);
        final bottleList = proceduralData.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
        _levelCache[levelId] = bottleList;
        return bottleList.map((b) => b.clone()).toList();
      }
    } else {
      final proceduralData = ProceduralLevelGenerator.generateLevel(levelId: levelId);
      final bottleList = proceduralData.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
      _levelCache[levelId] = bottleList;
      return bottleList.map((b) => b.clone()).toList();
    }
  }

  static void clearCache() {
    _levelCache.clear();
  }
}
