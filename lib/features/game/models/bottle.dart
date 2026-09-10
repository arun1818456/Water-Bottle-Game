import 'dart:math';
import '../../../core/constants/app_constants.dart';

/// Representation of a single bottle with water layers
class Bottle {
  final int capacity;
  final List<int> layers; // Ordered from bottom (index 0) to top (last index)

  Bottle({
    this.capacity = AppConstants.maxBottleCapacity,
    List<int>? layers,
  }) : layers = layers ?? <int>[];

  bool get isEmpty => layers.isEmpty;
  bool get isNotEmpty => layers.isNotEmpty;
  bool get isFull => layers.length >= capacity;
  int get availableSpace => capacity - layers.length;

  int? get topColor => layers.isNotEmpty ? layers.last : null;

  /// Number of contiguous layers of the same color at the top
  int get topColorCount {
    if (isEmpty) return 0;
    final top = layers.last;
    var count = 0;
    for (var i = layers.length - 1; i >= 0; i--) {
      if (layers[i] == top) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// A bottle is completed if it is empty, or full with exactly one color
  bool get isCompleted {
    if (isEmpty) return true;
    if (layers.length != capacity) return false;
    final firstColor = layers.first;
    return layers.every((c) => c == firstColor);
  }

  /// True if all liquid currently in bottle has the same color
  bool get isPure {
    if (isEmpty) return false;
    final firstColor = layers.first;
    return layers.every((c) => c == firstColor);
  }

  /// Can we pour from this bottle into [target]?
  bool canPourInto(Bottle target) {
    if (isEmpty) return false;
    if (target.isFull) return false;
    if (target.isEmpty) return true;
    return target.topColor == topColor;
  }

  /// Calculates how many layers will be transferred in a pour to [target]
  int calculatePourAmount(Bottle target) {
    if (!canPourInto(target)) return 0;
    return min(topColorCount, target.availableSpace);
  }

  /// Pours matching top liquid from this bottle into [target].
  /// Returns the number of layers poured.
  int pourInto(Bottle target) {
    final amount = calculatePourAmount(target);
    if (amount == 0) return 0;

    for (var i = 0; i < amount; i++) {
      final color = layers.removeLast();
      target.layers.add(color);
    }
    return amount;
  }

  Bottle clone() {
    return Bottle(
      capacity: capacity,
      layers: List<int>.from(layers),
    );
  }

  @override
  String toString() => 'Bottle(${layers.join(',')})';
}
