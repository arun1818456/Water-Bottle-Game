import 'bottle.dart';

/// Represents a single completed pour move for Undo history
class GameMove {
  final int fromIndex;
  final int toIndex;
  final int color;
  final int amount;
  final Set<int> sourceHiddenBefore;
  final Set<int> targetHiddenBefore;

  GameMove({
    required this.fromIndex,
    required this.toIndex,
    required this.color,
    required this.amount,
    Set<int>? sourceHiddenBefore,
    Set<int>? targetHiddenBefore,
  })  : sourceHiddenBefore = sourceHiddenBefore != null ? Set<int>.from(sourceHiddenBefore) : <int>{},
        targetHiddenBefore = targetHiddenBefore != null ? Set<int>.from(targetHiddenBefore) : <int>{};

  /// Reverts this move on the given list of bottles
  void undo(List<Bottle> bottles) {
    if (fromIndex < 0 || fromIndex >= bottles.length) return;
    if (toIndex < 0 || toIndex >= bottles.length) return;

    final targetBottle = bottles[toIndex];
    final sourceBottle = bottles[fromIndex];

    for (var i = 0; i < amount; i++) {
      if (targetBottle.layers.isNotEmpty) {
        final c = targetBottle.layers.removeLast();
        sourceBottle.layers.add(c);
      }
    }

    sourceBottle.hiddenIndices
      ..clear()
      ..addAll(sourceHiddenBefore);
    targetBottle.hiddenIndices
      ..clear()
      ..addAll(targetHiddenBefore);

    sourceBottle.checkAndRevealTop();
    targetBottle.checkAndRevealTop();
  }

  @override
  String toString() => 'Move(from: $fromIndex, to: $toIndex, color: $color, amount: $amount)';
}

