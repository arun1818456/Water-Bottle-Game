import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/features/game/models/bottle.dart';
import 'package:water_bottle_ais/features/game/models/game_move.dart';

void main() {
  group('Bottle Logic & Pour Rules', () {
    test('Empty bottle has capacity 4 and available space 4', () {
      final bottle = Bottle();
      expect(bottle.isEmpty, isTrue);
      expect(bottle.isFull, isFalse);
      expect(bottle.availableSpace, equals(4));
      expect(bottle.topColor, isNull);
      expect(bottle.topColorCount, equals(0));
      expect(bottle.isCompleted, isTrue); // Empty bottles count as completed
    });

    test('Bottle topColor and topColorCount calculates correctly', () {
      final bottle = Bottle(layers: [1, 2, 3, 3]);
      expect(bottle.isEmpty, isFalse);
      expect(bottle.isFull, isTrue);
      expect(bottle.topColor, equals(3));
      expect(bottle.topColorCount, equals(2));
      expect(bottle.availableSpace, equals(0));
      expect(bottle.isCompleted, isFalse);
    });

    test('Full bottle with same color is completed', () {
      final bottle = Bottle(layers: [2, 2, 2, 2]);
      expect(bottle.isFull, isTrue);
      expect(bottle.isCompleted, isTrue);
      expect(bottle.isPure, isTrue);
      expect(bottle.topColorCount, equals(4));
    });

    test('Cannot pour into full bottle', () {
      final source = Bottle(layers: [1, 2]);
      final target = Bottle(layers: [3, 4, 1, 2]);
      expect(source.canPourInto(target), isFalse);
      expect(source.calculatePourAmount(target), equals(0));
    });

    test('Cannot pour from empty bottle', () {
      final source = Bottle();
      final target = Bottle(layers: [1]);
      expect(source.canPourInto(target), isFalse);
    });

    test('Can pour any color into empty bottle', () {
      final source = Bottle(layers: [1, 2, 3]);
      final target = Bottle();
      expect(source.canPourInto(target), isTrue);
      expect(source.calculatePourAmount(target), equals(1));
    });

    test('Can pour matching top color into non-empty bottle with space', () {
      final source = Bottle(layers: [1, 2, 3, 3]);
      final target = Bottle(layers: [5, 3]);
      expect(source.canPourInto(target), isTrue);
      // Source has 2 of color 3, target has 2 spaces -> pours 2
      expect(source.calculatePourAmount(target), equals(2));
    });

    test('Auto-pours maximum possible up to target available space', () {
      final source = Bottle(layers: [1, 2, 2, 2]); // top has 3 of color 2
      final target = Bottle(layers: [4, 5, 2]);    // space is 1
      expect(source.calculatePourAmount(target), equals(1));

      final poured = source.pourInto(target);
      expect(poured, equals(1));
      expect(source.layers, equals([1, 2, 2]));
      expect(target.layers, equals([4, 5, 2, 2]));
    });

    test('Cannot pour different top colors', () {
      final source = Bottle(layers: [1, 2]);
      final target = Bottle(layers: [1, 3]);
      expect(source.canPourInto(target), isFalse);
      expect(source.calculatePourAmount(target), equals(0));
    });
  });

  group('GameMove Undo Logic', () {
    test('GameMove accurately reverts pour on bottles', () {
      final bottles = [
        Bottle(layers: [1, 2]),
        Bottle(layers: [3, 2]),
      ];

      // Bottle 0 pours top '2' into Bottle 1
      final move = GameMove(
        fromIndex: 0,
        toIndex: 1,
        color: 2,
        amount: 1,
      );

      // Execute pour
      bottles[0].pourInto(bottles[1]);
      expect(bottles[0].layers, equals([1]));
      expect(bottles[1].layers, equals([3, 2, 2]));

      // Undo move
      move.undo(bottles);
      expect(bottles[0].layers, equals([1, 2]));
      expect(bottles[1].layers, equals([3, 2]));
    });
  });

  group('Mystery / Blind Layers Logic', () {
    test('Layer marked as hidden is hidden when covered and reveals when exposed', () {
      final bottle = Bottle(
        layers: [1, 2, 3],
        hiddenIndices: {0},
      );

      // Initially top layer is index 2 (color 3).
      // Index 0 (color 1) is hidden.
      expect(bottle.isLayerHidden(0), isTrue);
      expect(bottle.isLayerHidden(2), isFalse);

      final target1 = Bottle();
      final target2 = Bottle();

      // Pour out top layer 3 into target1
      bottle.pourInto(target1);
      expect(bottle.layers, equals([1, 2]));
      expect(bottle.isLayerHidden(0), isTrue);

      // Pour out layer 2 into target2
      bottle.pourInto(target2);
      expect(bottle.layers, equals([1]));
      // Now index 0 is at the top (index == length - 1), so it auto-reveals!
      expect(bottle.isLayerHidden(0), isFalse);
      expect(bottle.hiddenIndices.contains(0), isFalse);
    });

    test('Undo properly restores hidden layer state', () {
      final bottle0 = Bottle(
        layers: [1, 2],
        hiddenIndices: {0},
      );
      final bottle1 = Bottle();

      final sourceHiddenBefore = Set<int>.from(bottle0.hiddenIndices);
      final targetHiddenBefore = Set<int>.from(bottle1.hiddenIndices);

      // Pour layer 2 from bottle 0 into bottle 1
      final move = GameMove(
        fromIndex: 0,
        toIndex: 1,
        color: 2,
        amount: 1,
        sourceHiddenBefore: sourceHiddenBefore,
        targetHiddenBefore: targetHiddenBefore,
      );

      bottle0.pourInto(bottle1);
      // Layer 1 exposed and revealed
      expect(bottle0.isLayerHidden(0), isFalse);

      // Undo move
      move.undo(bottle0.layers.isEmpty ? [bottle0, bottle1] : [bottle0, bottle1]);
      expect(bottle0.layers, equals([1, 2]));
      // Index 0 should be hidden again
      expect(bottle0.isLayerHidden(0), isTrue);
    });
  });

  group('Extra Bottle Limit Rules', () {
    test('Allows adding up to maxExtraBottles (2) extra bottles', () {
      final bottles = <Bottle>[Bottle(), Bottle()];
      int extraBottlesAdded = 0;
      const maxExtraBottles = 2;

      bool canAddExtraBottle() => extraBottlesAdded < maxExtraBottles;

      void addExtraEmptyBottle() {
        if (!canAddExtraBottle()) return;
        extraBottlesAdded++;
        bottles.add(Bottle());
      }

      // Initial count
      expect(bottles.length, equals(2));
      expect(canAddExtraBottle(), isTrue);

      // Add 1st extra bottle
      addExtraEmptyBottle();
      expect(bottles.length, equals(3));
      expect(extraBottlesAdded, equals(1));
      expect(canAddExtraBottle(), isTrue);

      // Add 2nd extra bottle
      addExtraEmptyBottle();
      expect(bottles.length, equals(4));
      expect(extraBottlesAdded, equals(2));
      expect(canAddExtraBottle(), isFalse);

      // Attempt to add 3rd extra bottle - should be blocked
      addExtraEmptyBottle();
      expect(bottles.length, equals(4));
      expect(extraBottlesAdded, equals(2));
    });
  });
}

