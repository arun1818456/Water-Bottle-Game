import 'package:water_bottle_ais/exports.dart';

/// Represents a single completed pour move for Undo history
class GameMove {
  final int fromIndex;
  final int toIndex;
  final int color;
  final int amount;

  const GameMove({
    required this.fromIndex,
    required this.toIndex,
    required this.color,
    required this.amount,
  });

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
  }

  @override
  String toString() => 'Move(from: $fromIndex, to: $toIndex, color: $color, amount: $amount)';
}
