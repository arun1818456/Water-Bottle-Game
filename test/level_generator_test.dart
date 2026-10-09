import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/exports.dart';

void main() {
  group('ProceduralLevelGenerator Tests', () {
    test('Generates level beyond 120 with valid structure', () {
      final level = ProceduralLevelGenerator.generateLevel(levelId: 125);

      expect(level.id, equals(125));
      expect(level.bottleCount, greaterThan(0));
      expect(level.emptyBottles, greaterThanOrEqualTo(1));
      expect(level.bottles.length, equals(level.bottleCount));

      final colorCounts = <int, int>{};
      for (final bottle in level.bottles) {
        for (final c in bottle) {
          colorCounts[c] = (colorCounts[c] ?? 0) + 1;
        }
      }

      for (final entry in colorCounts.entries) {
        expect(entry.value, equals(4),
            reason: 'Color ${entry.key} does not have exactly 4 segments');
      }

      final bottles = level.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
      expect(WaterSortSolver.hasAnyValidMove(bottles), isTrue);
    });

    test('Json serialization and deserialization preserves LevelData', () {
      final original = ProceduralLevelGenerator.generateLevel(levelId: 150);
      final json = original.toJson();
      final deserialized = LevelData.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.bottleCount, equals(original.bottleCount));
      expect(deserialized.emptyBottles, equals(original.emptyBottles));
      expect(deserialized.bottles, equals(original.bottles));
    });
  });
}
