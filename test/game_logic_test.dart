import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/exports.dart';

void main() {
  group('Bottle Logic & Pour Rules', () {
    test('Empty bottle has capacity 4 and available space 4', () {
      final bottle = Bottle();
      expect(bottle.isEmpty, isTrue);
      expect(bottle.isFull, isFalse);
      expect(bottle.availableSpace, equals(4));
      expect(bottle.topColor, isNull);
      expect(bottle.topColorCount, equals(0));
      expect(bottle.isCompleted, isTrue);
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
      expect(source.calculatePourAmount(target), equals(2));
    });

    test('Auto-pours maximum possible up to target available space', () {
      final source = Bottle(layers: [1, 2, 2, 2]);
      final target = Bottle(layers: [4, 5, 2]);
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

      final move = GameMove(
        fromIndex: 0,
        toIndex: 1,
        color: 2,
        amount: 1,
      );

      bottles[0].pourInto(bottles[1]);
      expect(bottles[0].layers, equals([1]));
      expect(bottles[1].layers, equals([3, 2, 2]));

      move.undo(bottles);
      expect(bottles[0].layers, equals([1, 2]));
      expect(bottles[1].layers, equals([3, 2]));
    });
  });
}
