import 'dart:math';
import '../../../core/constants/app_constants.dart';

/// Representation of a single bottle with water layers
class Bottle {
  final int capacity;
  final List<int> layers; // Ordered from bottom (index 0) to top (last index)
  final Set<int> hiddenIndices; // Set of layer indices that are blind/hidden until exposed

  Bottle({
    this.capacity = AppConstants.maxBottleCapacity,
    List<int>? layers,
    Set<int>? hiddenIndices,
  })  : layers = layers ?? <int>[],
        hiddenIndices = hiddenIndices ?? <int>{};

  bool get isEmpty => layers.isEmpty;
  bool get isNotEmpty => layers.isNotEmpty;
  bool get isFull => layers.length >= capacity;
  int get availableSpace => capacity - layers.length;

  int? get topColor => layers.isNotEmpty ? layers.last : null;

  /// Returns true if layer at [index] is currently hidden/blind.
  /// Top exposed layer is never hidden (it gets revealed automatically).
  bool isLayerHidden(int index) {
    if (index < 0 || index >= layers.length) return false;
    return hiddenIndices.contains(index) && index < layers.length - 1;
  }

  /// Automatically reveals top layer if it was hidden. Returns true if a layer was just revealed.
  bool checkAndRevealTop() {
    if (layers.isEmpty) return false;
    final topIndex = layers.length - 1;
    if (hiddenIndices.contains(topIndex)) {
      hiddenIndices.remove(topIndex);
      return true;
    }
    return false;
  }

  /// Number of contiguous layers of the same color at the top
  int get topColorCount {
    if (isEmpty) return 0;
    final top = layers.last;
    var count = 0;
    for (var i = layers.length - 1; i >= 0; i--) {
      if (layers[i] == top && !isLayerHidden(i)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// A bottle is completed if it is empty, or full with exactly one color and no hidden layers
  bool get isCompleted {
    if (isEmpty) return true;
    if (layers.length != capacity) return false;
    if (hiddenIndices.isNotEmpty) return false;
    final firstColor = layers.first;
    return layers.every((c) => c == firstColor);
  }

  /// True if all liquid currently in bottle has the same color and no hidden layers
  bool get isPure {
    if (isEmpty) return false;
    if (hiddenIndices.isNotEmpty) return false;
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
      hiddenIndices.remove(layers.length); // Clear hidden state at old index
      target.layers.add(color);
    }
    checkAndRevealTop();
    target.checkAndRevealTop();
    return amount;
  }

  Bottle clone() {
    return Bottle(
      capacity: capacity,
      layers: List<int>.from(layers),
      hiddenIndices: Set<int>.from(hiddenIndices),
    );
  }

  @override
  String toString() => 'Bottle(${layers.join(',')}, hidden: ${hiddenIndices.join(',')})';
}

