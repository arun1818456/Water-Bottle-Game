import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/features/game/logic/procedural_level_generator.dart';
import 'package:water_bottle_ais/features/game/logic/water_sort_solver.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';
void main() {
  group('ProceduralLevelGenerator Tests', () {
    test('Generates level beyond 120 with valid structure', () {
      final level = ProceduralLevelGenerator.generateLevel(125);

      expect(level.id, equals(125));
      expect(level.bottleCount, greaterThan(0));
      expect(level.emptyBottles, greaterThanOrEqualTo(1));
      expect(level.bottles.length, equals(level.bottleCount));

      // Verify that every color has exactly 4 occurrences in total
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

      // Verify playable
      final bottles = level.bottles.map((b) => Bottle(layers: List<int>.from(b))).toList();
      expect(WaterSortSolver.hasAnyValidMove(bottles), isTrue);
    });

    test('Json serialization and deserialization preserves LevelData', () {
      final original = ProceduralLevelGenerator.generateLevel(150);
      final json = original.toJson();
      final deserialized = LevelData.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.bottleCount, equals(original.bottleCount));
      expect(deserialized.emptyBottles, equals(original.emptyBottles));
      expect(deserialized.bottles, equals(original.bottles));
    });
  });
}
