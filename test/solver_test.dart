import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/exports.dart';

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
      final puzzle = [
        Bottle(layers: [1, 1, 1]),
        Bottle(layers: [2, 2, 2, 1]),
        Bottle(layers: [2]),
      ];

      final solution = WaterSortSolver.solve(puzzle);
      expect(solution, isNotNull);
      final hint = solution!.first;
      expect(hint.fromIndex, equals(1));
      expect(hint.toIndex, equals(0));
      expect(hint.color, equals(1));
    });

    test('hasAnyValidMove detects deadlock when no moves are possible', () {
      final deadlocked = [
        Bottle(layers: [1, 2, 1, 2]),
        Bottle(layers: [2, 1, 2, 1]),
      ];

      expect(WaterSortSolver.hasAnyValidMove(deadlocked), isFalse);
    });

    test('hasAnyValidMove detects when moves exist', () {
      final playable = [
        Bottle(layers: [1, 2, 1, 2]),
        Bottle(layers: [2, 1, 2]),
      ];

      expect(WaterSortSolver.hasAnyValidMove(playable), isTrue);
    });
  });
}
