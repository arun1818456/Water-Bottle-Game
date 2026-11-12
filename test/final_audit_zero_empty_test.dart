import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/features/game/logic/procedural_level_generator.dart';
import 'package:water_bottle_ais/features/game/logic/water_sort_solver.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';

void main() {
  test('Final audit of all 400 levels with zero empty bottles requirement', () {
    final issues = <String>[];
    
    for (int i = 1; i <= 400; i++) {
      final padded = i.toString().padLeft(3, '0');
      final file = File('assets/levels/level_$padded.json');
      if (!file.existsSync()) {
        issues.add('Level $i: File assets/levels/level_$padded.json missing');
        continue;
      }
      
      try {
        final content = file.readAsStringSync();
        final jsonMap = jsonDecode(content) as Map<String, dynamic>;
        
        final levelData = LevelData.fromJson(jsonMap);
        
        // Check if levels 180, 246, 366 have emptyBottles == 0
        if ([180, 246, 366].contains(i)) {
          if (levelData.emptyBottles != 0) {
            issues.add('Level $i: emptyBottles is ${levelData.emptyBottles} (expected 0)');
          }
        }
        
        // Check bottle count
        if (levelData.bottles.length != levelData.bottleCount) {
          issues.add('Level $i: bottleCount (${levelData.bottleCount}) does not match actual bottles length (${levelData.bottles.length})');
        }
        
        // Check color counts (each color should appear in groups of 4)
        final colorCounts = <int, int>{};
        for (final b in levelData.bottles) {
          for (final c in b) {
            colorCounts[c] = (colorCounts[c] ?? 0) + 1;
          }
        }
        
        for (final entry in colorCounts.entries) {
          if (entry.value != 4) {
            issues.add('Level $i: Color ${entry.key} appears ${entry.value} times (expected 4)');
          }
        }
        
        // Check if level has valid moves
        final bottles = levelData.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
        if (!WaterSortSolver.hasAnyValidMove(bottles) && !WaterSortSolver.isSolved(bottles)) {
          issues.add('Level $i: Deadlocked at start (no valid initial moves)');
        }
        
      } catch (e) {
        issues.add('Level $i: Error parsing or auditing - $e');
      }
    }
    
    print('========================================');
    print('TOTAL ISSUES FOUND: ${issues.length}');
    print('========================================');
    for (final issue in issues) {
      print(issue);
    }
    
    expect(issues, isEmpty, reason: 'Found ${issues.length} issues across level files.');
  });
}
