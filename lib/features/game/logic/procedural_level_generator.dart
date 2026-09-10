import 'dart:math';
import '../models/bottle.dart';
import 'water_sort_solver.dart';

/// Level configuration model
class LevelData {
  final int id;
  final String difficulty;
  final int bottleCount;
  final int emptyBottles;
  final List<List<int>> bottles;

  LevelData({
    required this.id,
    required this.difficulty,
    required this.bottleCount,
    required this.emptyBottles,
    required this.bottles,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    final rawBottles = json['bottles'] as List;
    final parsedBottles = rawBottles.map((b) => List<int>.from(b as List)).toList();

    return LevelData(
      id: json['id'] as int,
      difficulty: json['difficulty'] as String? ?? 'Custom',
      bottleCount: json['bottleCount'] as int? ?? parsedBottles.length,
      emptyBottles: json['emptyBottles'] as int? ??
          parsedBottles.where((b) => b.isEmpty).length,
      bottles: parsedBottles,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'bottleCount': bottleCount,
        'emptyBottles': emptyBottles,
        'bottles': bottles,
      };
}

/// Procedural level generator for infinite levels beyond level 120
class ProceduralLevelGenerator {
  ProceduralLevelGenerator._();

  static LevelData generateLevel(int levelId) {
    // Determine difficulty parameters based on level number
    int colorCount;
    int emptyBottles = 2;

    if (levelId <= 140) {
      colorCount = 8;
    } else if (levelId <= 170) {
      colorCount = 9;
    } else if (levelId <= 200) {
      colorCount = 10;
    } else if (levelId <= 250) {
      colorCount = 11;
    } else {
      colorCount = min(14, 12 + ((levelId - 250) ~/ 50));
      emptyBottles = (colorCount >= 12) ? 3 : 2;
    }

    var seed = 50000 + levelId * 101;
    final maxAttempts = 50;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final rand = Random(seed + attempt);

      // Create pool of 4 units per color
      final colorPool = <int>[];
      for (var c = 1; c <= colorCount; c++) {
        for (var k = 0; k < 4; k++) {
          colorPool.add(c);
        }
      }
      colorPool.shuffle(rand);

      final bottles = <List<int>>[];
      for (var i = 0; i < colorCount; i++) {
        bottles.add(colorPool.sublist(i * 4, (i + 1) * 4));
      }
      for (var e = 0; e < emptyBottles; e++) {
        bottles.add(<int>[]);
      }

      // Check that no bottle is already pure
      var hasPure = false;
      for (var i = 0; i < colorCount; i++) {
        if (bottles[i].every((c) => c == bottles[i].first)) {
          hasPure = true;
          break;
        }
      }
      if (hasPure) continue;

      // Verify immediate moves exist
      final bottleModels = bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
      if (WaterSortSolver.hasAnyValidMove(bottleModels)) {
        return LevelData(
          id: levelId,
          difficulty: _getDifficultyTitle(levelId),
          bottleCount: bottles.length,
          emptyBottles: emptyBottles,
          bottles: bottles,
        );
      }
    }

    // Solvable-by-construction reverse fallback
    return _generateReverseSolvable(levelId, colorCount, emptyBottles);
  }

  static LevelData _generateReverseSolvable(int levelId, int colorCount, int emptyBottles) {
    final rand = Random(9999 + levelId * 17);
    final bottles = List.generate(
      colorCount,
      (i) => List<int>.filled(4, i + 1, growable: true),
    );
    for (var i = 0; i < emptyBottles; i++) {
      bottles.add(<int>[]);
    }

    final steps = 25 + min(60, levelId ~/ 3);
    for (var s = 0; s < steps; s++) {
      final nonEmpties = <int>[];
      for (var i = 0; i < bottles.length; i++) {
        if (bottles[i].isNotEmpty) nonEmpties.add(i);
      }
      if (nonEmpties.isEmpty) break;

      final from = nonEmpties[rand.nextInt(nonEmpties.length)];
      final targets = <int>[];
      for (var j = 0; j < bottles.length; j++) {
        if (j != from && bottles[j].length < 4) {
          targets.add(j);
        }
      }
      if (targets.isEmpty) continue;
      final to = targets[rand.nextInt(targets.length)];

      bottles[to].add(bottles[from].removeLast());
    }

    return LevelData(
      id: levelId,
      difficulty: _getDifficultyTitle(levelId),
      bottleCount: bottles.length,
      emptyBottles: bottles.where((b) => b.isEmpty).length,
      bottles: bottles,
    );
  }

  static String _getDifficultyTitle(int levelId) {
    if (levelId <= 140) return 'Master+';
    if (levelId <= 200) return 'Grandmaster';
    return 'Aqua Legend';
  }
}
