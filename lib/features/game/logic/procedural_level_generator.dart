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
  final List<Set<int>>? hiddenLayers;

  LevelData({
    required this.id,
    required this.difficulty,
    required this.bottleCount,
    required this.emptyBottles,
    required this.bottles,
    this.hiddenLayers,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    final rawBottles = json['bottles'] as List;
    final parsedBottles = <List<int>>[];
    final parsedHidden = <Set<int>>[];

    for (var b in rawBottles) {
      if (b is Map<String, dynamic>) {
        parsedBottles.add(List<int>.from(b['layers'] as List));
        if (b.containsKey('hidden')) {
          parsedHidden.add(Set<int>.from((b['hidden'] as List).cast<int>()));
        } else {
          parsedHidden.add(<int>{});
        }
      } else if (b is List) {
        parsedBottles.add(List<int>.from(b));
        parsedHidden.add(<int>{});
      }
    }

    // Auto-enrich levels with mystery layers if not explicitly defined
    if (!parsedHidden.any((s) => s.isNotEmpty)) {
      final levelId = json['id'] as int? ?? 1;
      final diff = json['difficulty'] as String? ?? 'Custom';
      final isHard = diff == 'Hard' ||
          diff == 'Expert' ||
          diff == 'Very Hard' ||
          diff == 'Master+' ||
          diff == 'Grandmaster' ||
          diff == 'Aqua Legend';

      // Show mystery layers on ALL hard levels, and periodically on medium/easy levels >= 5
      final isPeriodic = levelId >= 5 && (levelId % 2 == 0 || levelId % 3 == 0);

      if (isHard || isPeriodic) {
        final rand = Random(levelId * 7919);
        final eligibleIndices = <int>[];
        for (var i = 0; i < parsedBottles.length; i++) {
          if (parsedBottles[i].length >= 3) {
            eligibleIndices.add(i);
          }
        }

        if (eligibleIndices.isNotEmpty) {
          eligibleIndices.shuffle(rand);
          final countToHide = isHard
              ? min(eligibleIndices.length, 3)
              : min(eligibleIndices.length, 2);

          for (var k = 0; k < countToHide; k++) {
            final idx = eligibleIndices[k];
            parsedHidden[idx].add(0); // Hide bottom layer
            if (parsedBottles[idx].length >= 4 && (isHard || k == 0 || levelId % 4 == 0)) {
              parsedHidden[idx].add(1); // Hide second layer
            }
          }
        }
      }
    }

    return LevelData(
      id: json['id'] as int,
      difficulty: json['difficulty'] as String? ?? 'Custom',
      bottleCount: json['bottleCount'] as int? ?? parsedBottles.length,
      emptyBottles: json['emptyBottles'] as int? ??
          parsedBottles.where((b) => b.isEmpty).length,
      bottles: parsedBottles,
      hiddenLayers: parsedHidden.any((s) => s.isNotEmpty) ? parsedHidden : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'bottleCount': bottleCount,
        'emptyBottles': emptyBottles,
        'bottles': List.generate(bottles.length, (i) {
          final hidden = (hiddenLayers != null && i < hiddenLayers!.length)
              ? hiddenLayers![i].toList()
              : <int>[];
          if (hidden.isNotEmpty) {
            return {'layers': bottles[i], 'hidden': hidden};
          }
          return bottles[i];
        }),
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
        final hidden = _generateMysteryLayers(levelId, bottles, rand);
        return LevelData(
          id: levelId,
          difficulty: _getDifficultyTitle(levelId),
          bottleCount: bottles.length,
          emptyBottles: emptyBottles,
          bottles: bottles,
          hiddenLayers: hidden,
        );
      }
    }

    // Solvable-by-construction reverse fallback (more shuffling for uniqueness)
    return _generateReverseSolvable(levelId, colorCount, emptyBottles);
  }

  static List<Set<int>>? _generateMysteryLayers(
    int levelId,
    List<List<int>> bottles,
    Random rand,
  ) {
    if (levelId < 8) return null;
    final hiddenLayers = List.generate(bottles.length, (_) => <int>{});
    final eligibleIndices = <int>[];

    for (var i = 0; i < bottles.length; i++) {
      if (bottles[i].length >= 3) {
        eligibleIndices.add(i);
      }
    }

    if (eligibleIndices.isNotEmpty) {
      eligibleIndices.shuffle(rand);
      final countToHide = min(eligibleIndices.length, levelId >= 20 ? 3 : 2);
      for (var k = 0; k < countToHide; k++) {
        final idx = eligibleIndices[k];
        hiddenLayers[idx].add(0); // Hide bottom layer
        if (bottles[idx].length >= 4 && (k % 2 == 0 || levelId >= 25)) {
          hiddenLayers[idx].add(1); // Hide second layer too for added thrill
        }
      }
    }

    return hiddenLayers.any((s) => s.isNotEmpty) ? hiddenLayers : null;
  }

  static LevelData _generateReverseSolvable(int levelId, int colorCount, int emptyBottles) {
    final rand = Random(levelId.hashCode ^ 87654321);
    
    final bottles = List.generate(
      colorCount,
      (i) => List<int>.filled(4, i + 1, growable: true),
    );
    for (var i = 0; i < emptyBottles; i++) {
      bottles.add(<int>[]);
    }

    final steps = 150 + min(200, levelId * 2);
    
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
    
    final colors = List.generate(colorCount, (i) => i + 1);
    colors.shuffle(rand);
    final colorMap = <int, int>{};
    for (var i = 0; i < colors.length; i++) {
      colorMap[i + 1] = colors[i];
    }
    
    for (var i = 0; i < bottles.length; i++) {
      for (var j = 0; j < bottles[i].length; j++) {
         bottles[i][j] = colorMap[bottles[i][j]]!;
      }
    }
    
    bottles.shuffle(rand);

    final hidden = _generateMysteryLayers(levelId, bottles, rand);

    return LevelData(
      id: levelId,
      difficulty: _getDifficultyTitle(levelId),
      bottleCount: bottles.length,
      emptyBottles: bottles.where((b) => b.isEmpty).length,
      bottles: bottles,
      hiddenLayers: hidden,
    );
  }

  static String _getDifficultyTitle(int levelId) {
    if (levelId <= 140) return 'Master+';
    if (levelId <= 200) return 'Grandmaster';
    return 'Aqua Legend';
  }
}

