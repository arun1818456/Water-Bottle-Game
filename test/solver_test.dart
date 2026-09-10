import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/features/game/logic/water_sort_solver.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';

void main() {
  group('WaterSortSolver Tests', () {
    test('isSolved returns true when all bottles are completed or empty', () {
      final solvedBottles = [
        Bottle(layers: [1, 1, 1, 1]),
        Bottle(layers: [2, 2, 2, 2]),
        Bottle(),
      ];
      expect(WaterSortSolver.isSolved(solvedBottles), isTrue);
    });

    test('isSolved returns false when any bottle is mixed', () {
      final mixedBottles = [
        Bottle(layers: [1, 2, 1, 1]),
        Bottle(layers: [2, 1, 2, 2]),
        Bottle(),
      ];
      expect(WaterSortSolver.isSolved(mixedBottles), isFalse);
    });

    test('findNextHint provides optimal first move towards solution', () {
      // Simple 1-move-to-solve puzzle
      final puzzle = [
        Bottle(layers: [1, 1, 1]),
        Bottle(layers: [2, 2, 2, 1]),
        Bottle(layers: [2]),
      ];

      final hint = WaterSortSolver.findNextHint(puzzle);
      expect(hint, isNotNull);
      // Moving 1 from bottle 1 to bottle 0 completes bottle 0
      expect(hint!.fromIndex, equals(1));
      expect(hint.toIndex, equals(0));
      expect(hint.color, equals(1));
    });

    test('hasAnyValidMove detects deadlock when no moves are possible', () {
      // 2 bottles full with no matching tops and no empty bottle
      final deadlocked = [
        Bottle(layers: [1, 2, 1, 2]),
        Bottle(layers: [2, 1, 2, 1]),
      ];

      expect(WaterSortSolver.hasAnyValidMove(deadlocked), isFalse);
    });

    test('hasAnyValidMove detects when moves exist', () {
      final playable = [
        Bottle(layers: [1, 2, 1, 2]),
        Bottle(layers: [2, 1, 2]), // has space for 2!
      ];

      expect(WaterSortSolver.hasAnyValidMove(playable), isTrue);
    });
  });
}
