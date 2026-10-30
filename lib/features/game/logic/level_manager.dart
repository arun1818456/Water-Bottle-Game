import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart';
import 'procedural_level_generator.dart';

/// LevelManager handles loading of handcrafted JSON levels and procedural fallback
class LevelManager {
  LevelManager._();

  static final Map<int, LevelData> _levelCache = {};

  static Future<LevelData> loadLevel(int levelId) async {
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId]!;
    }

    if (levelId <= AppConstants.totalHandcraftedLevels) {
      try {
        final path = AssetsConstants.getLevelPath(levelId);
        final jsonString = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final levelData = LevelData.fromJson(jsonMap);
        _levelCache[levelId] = levelData;
        return levelData;
      } catch (e) {
        // Fallback gracefully to procedural generation if level asset is unavailable or fails to parse
        final procedural = ProceduralLevelGenerator.generateLevel(levelId);
        _levelCache[levelId] = procedural;
        return procedural;
      }
    } else {
      // Procedural generation for infinite levels beyond handcrafted range
      final procedural = ProceduralLevelGenerator.generateLevel(levelId);
      _levelCache[levelId] = procedural;
      return procedural;
    }
  }

  static void clearCache() {
    _levelCache.clear();
  }
}
