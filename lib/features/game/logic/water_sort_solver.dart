import 'dart:collection';
import 'dart:math';
import '../models/bottle.dart';

class HintMove {
  final int fromIndex;
  final int toIndex;
  final int color;
  final int amount;

  const HintMove({
    required this.fromIndex,
    required this.toIndex,
    required this.color,
    required this.amount,
  });

  @override
  String toString() => 'Hint(from: $fromIndex, to: $toIndex, color: $color)';
}

/// Advanced BFS Solver that finds optimal moves for hints and detects deadlocks
class WaterSortSolver {
  WaterSortSolver._();

  /// Checks if the board has reached the winning state
  static bool isSolved(List<Bottle> bottles) {
    for (final bottle in bottles) {
      if (!bottle.isCompleted) return false;
    }
    return true;
  }

  /// Checks if any valid pour is possible on the current board
  static bool hasAnyValidMove(List<Bottle> bottles) {
    for (var from = 0; from < bottles.length; from++) {
      if (bottles[from].isEmpty) continue;
      // Don't count pouring from an already completed bottle
      if (bottles[from].isCompleted && bottles[from].isFull) continue;

      for (var to = 0; to < bottles.length; to++) {
        if (from == to) continue;
        if (bottles[to].isFull) continue;

        if (bottles[from].canPourInto(bottles[to])) {
          // If to is empty, moving a pure bottle is redundant unless it opens space
          if (bottles[to].isEmpty && bottles[from].isPure) {
            continue;
          }
          return true;
        }
      }
    }
    return false;
  }

  /// Finds the next optimal move using BFS. Returns null if unsolvable or already solved.
  static HintMove? findNextHint(List<Bottle> bottles, {int maxSearchNodes = 15000}) {
    if (isSolved(bottles)) return null;

    final queue = Queue<_SolverNode>();
    final visited = <String>{};

    // Deep copy initial state
    final initialLayers = bottles.map((b) => List<int>.from(b.layers)).toList();
    final startNode = _SolverNode(
      state: initialLayers,
      firstMove: null,
    );

    queue.add(startNode);
    visited.add(_canonicalHash(initialLayers));

    var nodesSearched = 0;

    while (queue.isNotEmpty && nodesSearched < maxSearchNodes) {
      nodesSearched++;
      final current = queue.removeFirst();

      // Check if current state is solved
      if (_isStateSolved(current.state)) {
        return current.firstMove;
      }

      // Generate next valid moves
      for (var from = 0; from < current.state.length; from++) {
        final fromLayers = current.state[from];
        if (fromLayers.isEmpty) continue;

        // Skip full completed bottles
        if (fromLayers.length == 4 && fromLayers.every((c) => c == fromLayers.first)) {
          continue;
        }

        final topColor = fromLayers.last;
        final topCount = _countTopColor(fromLayers);

        for (var to = 0; to < current.state.length; to++) {
          if (from == to) continue;
          final toLayers = current.state[to];
          if (toLayers.length >= 4) continue;

          // Pour rules
          if (toLayers.isEmpty) {
            // Avoid moving a pure stack to an empty bottle (wasted symmetric move)
            if (fromLayers.every((c) => c == topColor)) {
              continue;
            }
          } else if (toLayers.last != topColor) {
            continue;
          }

          final space = 4 - toLayers.length;
          final pourAmount = min(topCount, space);
          if (pourAmount <= 0) continue;

          // Apply move
          final nextState = current.state.map((l) => List<int>.from(l)).toList();
          for (var k = 0; k < pourAmount; k++) {
            nextState[to].add(nextState[from].removeLast());
          }

          final hash = _canonicalHash(nextState);
          if (!visited.contains(hash)) {
            visited.add(hash);

            final firstMove = current.firstMove ??
                HintMove(
                  fromIndex: from,
                  toIndex: to,
                  color: topColor,
                  amount: pourAmount,
                );

            queue.add(_SolverNode(
              state: nextState,
              firstMove: firstMove,
            ));
          }
        }
      }
    }

    // Fallback: If BFS reached node limit, return any immediate valid move
    for (var from = 0; from < bottles.length; from++) {
      if (bottles[from].isEmpty || (bottles[from].isCompleted && bottles[from].isFull)) continue;
      for (var to = 0; to < bottles.length; to++) {
        if (from == to || bottles[to].isFull) continue;
        if (bottles[from].canPourInto(bottles[to])) {
          if (bottles[to].isEmpty && bottles[from].isPure) continue;
          return HintMove(
            fromIndex: from,
            toIndex: to,
            color: bottles[from].topColor!,
            amount: bottles[from].calculatePourAmount(bottles[to]),
          );
        }
      }
    }

    return null;
  }

  static int _countTopColor(List<int> list) {
    if (list.isEmpty) return 0;
    final top = list.last;
    var count = 0;
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i] == top) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  static bool _isStateSolved(List<List<int>> state) {
    for (final b in state) {
      if (b.isEmpty) continue;
      if (b.length != 4) return false;
      final first = b.first;
      if (!b.every((c) => c == first)) return false;
    }
    return true;
  }

  static String _canonicalHash(List<List<int>> state) {
    final copy = state.map((b) => b.join(',')).toList()..sort();
    return copy.join('|');
  }
}

class _SolverNode {
  final List<List<int>> state;
  final HintMove? firstMove;

  _SolverNode({
    required this.state,
    required this.firstMove,
  });
}
