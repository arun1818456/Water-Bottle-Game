// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

void main() async {
  print('Generating and BFS-verifying 120 standard 4-layer Water Sort levels...');

  final levelsDir = Directory('assets/levels');
  await levelsDir.create(recursive: true);

  for (var lvl = 1; lvl <= 120; lvl++) {
    int colorCount;
    int emptyBottles = 2;

    if (lvl <= 20) {
      colorCount = (lvl <= 5) ? 2 : (lvl <= 12 ? 3 : 4);
      if (lvl <= 3) emptyBottles = 1;
    } else if (lvl <= 40) {
      colorCount = (lvl <= 30) ? 4 : 5;
    } else if (lvl <= 60) {
      colorCount = (lvl <= 50) ? 5 : 6;
    } else if (lvl <= 80) {
      colorCount = (lvl <= 70) ? 6 : 7;
    } else if (lvl <= 100) {
      colorCount = (lvl <= 90) ? 7 : 8;
    } else {
      colorCount = (lvl <= 110) ? 8 : 9;
    }

    final levelData = generateSolvableStandardLevel(lvl, colorCount, emptyBottles);

    final filename = 'assets/levels/level_${lvl.toString().padLeft(3, '0')}.json';
    await File(filename).writeAsString(
      const JsonEncoder.withIndent('  ').convert(levelData),
    );
  }

  print('120 standard levels generated successfully!');
}

Map<String, dynamic> generateSolvableStandardLevel(int levelId, int colorCount, int emptyBottles) {
  var seed = 2000 + levelId * 71;

  while (true) {
    final rand = Random(seed);

    // Create pool of colors: 4 of each color
    final colorPool = <int>[];
    for (var c = 1; c <= colorCount; c++) {
      for (var k = 0; k < 4; k++) {
        colorPool.add(c);
      }
    }
    colorPool.shuffle(rand);

    // Fill colorCount bottles with 4 segments each
    final bottles = <List<int>>[];
    for (var i = 0; i < colorCount; i++) {
      bottles.add(colorPool.sublist(i * 4, (i + 1) * 4));
    }
    // Add empty bottles
    for (var e = 0; e < emptyBottles; e++) {
      bottles.add(<int>[]);
    }

    // Check if any bottle is already purely 1 color (we want mixed bottles for good puzzles)
    var hasPureBottle = false;
    for (var i = 0; i < colorCount; i++) {
      if (bottles[i].every((c) => c == bottles[i].first)) {
        hasPureBottle = true;
        break;
      }
    }

    if (!hasPureBottle) {
      // Check solvability with BFS
      final moves = solveBFS(bottles, maxNodes: 12000);
      if (moves != null && moves.length >= 3) {
        return {
          "id": levelId,
          "difficulty": getDifficultyLabel(levelId),
          "bottleCount": bottles.length,
          "emptyBottles": emptyBottles,
          "bottles": bottles,
        };
      }
    }

    seed += 3;
  }
}

List<List<int>>? solveBFS(List<List<int>> initialBottles, {int maxNodes = 10000}) {
  final queue = Queue<BFSStep>();
  final visited = <String>{};

  final startState = initialBottles.map((b) => List<int>.from(b)).toList();
  queue.add(BFSStep(state: startState, moves: []));
  visited.add(canonicalHash(startState));

  var nodes = 0;
  while (queue.isNotEmpty && nodes < maxNodes) {
    nodes++;
    final step = queue.removeFirst();
    final state = step.state;

    if (isGoal(state)) {
      return step.moves;
    }

    // Find all valid moves
    for (var from = 0; from < state.length; from++) {
      if (state[from].isEmpty) continue;

      // Don't move from a bottle that is already full and pure
      if (state[from].length == 4 && state[from].every((c) => c == state[from].first)) {
        continue;
      }

      final topColor = state[from].last;
      final topCount = countTopColor(state[from]);

      for (var to = 0; to < state.length; to++) {
        if (from == to) continue;
        if (state[to].length == 4) continue;

        // If target bottle is empty, only move if source is not already pure
        if (state[to].isEmpty) {
          if (state[from].every((c) => c == topColor)) {
            continue; // Useless move: moving a pure stack to an empty bottle
          }
        } else if (state[to].last != topColor) {
          continue; // Different color
        }

        final space = 4 - state[to].length;
        final pourAmount = min(topCount, space);

        // Make move
        final nextState = state.map((b) => List<int>.from(b)).toList();
        for (var k = 0; k < pourAmount; k++) {
          nextState[to].add(nextState[from].removeLast());
        }

        final hash = canonicalHash(nextState);
        if (!visited.contains(hash)) {
          visited.add(hash);
          queue.add(BFSStep(
            state: nextState,
            moves: [...step.moves, [from, to]],
          ));
        }
      }
    }
  }

  return null; // Not solved within limit
}

class BFSStep {
  final List<List<int>> state;
  final List<List<int>> moves;
  BFSStep({required this.state, required this.moves});
}

int countTopColor(List<int> bottle) {
  if (bottle.isEmpty) return 0;
  final top = bottle.last;
  var count = 0;
  for (var i = bottle.length - 1; i >= 0; i--) {
    if (bottle[i] == top) {
      count++;
    } else {
      break;
    }
  }
  return count;
}

bool isGoal(List<List<int>> state) {
  for (final b in state) {
    if (b.isEmpty) continue;
    if (b.length != 4) return false;
    final first = b.first;
    if (!b.every((c) => c == first)) return false;
  }
  return true;
}

String canonicalHash(List<List<int>> state) {
  final list = state.map((b) => b.join(',')).toList()..sort();
  return list.join('|');
}

String getDifficultyLabel(int level) {
  if (level <= 20) return "Easy";
  if (level <= 40) return "Easy+";
  if (level <= 60) return "Medium";
  if (level <= 80) return "Hard";
  if (level <= 100) return "Expert";
  return "Master";
}
