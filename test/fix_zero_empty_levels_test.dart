import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/features/game/logic/procedural_level_generator.dart';
import 'package:water_bottle_ais/features/game/logic/water_sort_solver.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';

void main() {
  test('Generate valid levels 180, 246, 366 with emptyBottles: 0', () {
    for (final levelId in [180, 246, 366]) {
      final levelData = _generateZeroEmptyLevel(levelId);
      
      final jsonMap = levelData.toJson();
      jsonMap['emptyBottles'] = 0;
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
      
      final padded = levelId.toString().padLeft(3, '0');
      final file = File('assets/levels/level_$padded.json');
      file.writeAsStringSync(jsonString);
      print('Generated level $levelId with emptyBottles: 0');
    }
  });
}

LevelData _generateZeroEmptyLevel(int levelId) {
  int colorCount = 10;
  if (levelId > 300) {
    colorCount = 12;
  } else if (levelId > 200) {
    colorCount = 11;
  } else {
    colorCount = 10;
  }

  final rand = Random(levelId * 31337);
  
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
  // Add 2 extra bottles that will be partially filled (so emptyBottles count in json is 0, but space exists)
  bottles.add(<int>[]);
  bottles.add(<int>[]);

  final steps = 150 + levelId;
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
  
  // Ensure no 100% empty bottles remain (fill any empty bottle with 1-2 items)
  for (var i = 0; i < bottles.length; i++) {
    if (bottles[i].isEmpty) {
      for (var j = 0; j < bottles.length; j++) {
        if (bottles[j].length > 2) {
          bottles[i].add(bottles[j].removeLast());
          bottles[i].add(bottles[j].removeLast());
          break;
        }
      }
    }
  }

  bottles.shuffle(rand);

  return LevelData(
    id: levelId,
    difficulty: levelId > 300 ? 'Aqua Legend' : (levelId > 200 ? 'Grandmaster' : 'Hard'),
    bottleCount: bottles.length,
    emptyBottles: 0,
    bottles: bottles,
  );
}
