// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  print('--- Generating Game Assets ---');

  final audioDir = Directory('assets/audio');
  final imagesDir = Directory('assets/images');
  final lottieDir = Directory('assets/lottie');
  final levelsDir = Directory('assets/levels');

  await audioDir.create(recursive: true);
  await imagesDir.create(recursive: true);
  await lottieDir.create(recursive: true);
  await levelsDir.create(recursive: true);

  print('Generating audio WAV files...');
  await generateClickWav('assets/audio/click.wav');
  await generatePourWav('assets/audio/pour.wav');
  await generateWinWav('assets/audio/win.wav');
  await generateAmbientWav('assets/audio/ambient.wav');

  print('Generating celebration Lottie JSON...');
  await generateLottieCelebration('assets/lottie/win_celebration.json');

  print('Generating and validating 120 Solvable Handcrafted Level JSONs...');
  await generate120Levels();

  print('Asset generation complete!');
}

Uint8List createWavBytes(List<double> samples, int sampleRate) {
  final numSamples = samples.length;
  final byteRate = sampleRate * 2;
  final blockAlign = 2;
  final dataSize = numSamples * 2;
  final fileSize = 36 + dataSize;

  final bytes = ByteData(44 + dataSize);

  bytes.setUint8(0, 0x52);
  bytes.setUint8(1, 0x49);
  bytes.setUint8(2, 0x46);
  bytes.setUint8(3, 0x46);
  bytes.setUint32(4, fileSize, Endian.little);

  bytes.setUint8(8, 0x57);
  bytes.setUint8(9, 0x41);
  bytes.setUint8(10, 0x56);
  bytes.setUint8(11, 0x45);

  bytes.setUint8(12, 0x66);
  bytes.setUint8(13, 0x6D);
  bytes.setUint8(14, 0x74);
  bytes.setUint8(15, 0x20);
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, byteRate, Endian.little);
  bytes.setUint16(32, blockAlign, Endian.little);
  bytes.setUint16(34, 16, Endian.little);

  bytes.setUint8(36, 0x64);
  bytes.setUint8(37, 0x61);
  bytes.setUint8(38, 0x74);
  bytes.setUint8(39, 0x61);
  bytes.setUint32(40, dataSize, Endian.little);

  var offset = 44;
  for (var i = 0; i < numSamples; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    final sampleVal = (clamped * 32767).toInt();
    bytes.setInt16(offset, sampleVal, Endian.little);
    offset += 2;
  }

  return bytes.buffer.asUint8List();
}

Future<void> generateClickWav(String path) async {
  const sampleRate = 44100;
  final duration = 0.08;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final decay = exp(-t * 80);
    final s = (sin(2 * pi * 800 * t) + 0.5 * sin(2 * pi * 1600 * t)) * decay;
    samples.add(s * 0.7);
  }

  final bytes = createWavBytes(samples, sampleRate);
  await File(path).writeAsBytes(bytes);
}

Future<void> generatePourWav(String path) async {
  const sampleRate = 44100;
  final duration = 0.8;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final rand = Random(42);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = sin(pi * (t / duration));
    final freq = 450 + 120 * sin(2 * pi * 18 * t) + 80 * sin(2 * pi * 7 * t);
    final waterSine = sin(2 * pi * freq * t);
    final noise = (rand.nextDouble() * 2 - 1) * 0.25;
    final s = (waterSine * 0.75 + noise) * envelope;
    samples.add(s * 0.6);
  }

  final bytes = createWavBytes(samples, sampleRate);
  await File(path).writeAsBytes(bytes);
}

Future<void> generateWinWav(String path) async {
  const sampleRate = 44100;
  final duration = 1.2;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];

  final notes = [523.25, 659.25, 783.99, 1046.50];
  final noteDur = duration / notes.length;

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final noteIndex = (t / noteDur).floor().clamp(0, notes.length - 1);
    final noteTime = t - (noteIndex * noteDur);
    final noteFreq = notes[noteIndex];
    final decay = exp(-noteTime * 4.0);

    final s = (sin(2 * pi * noteFreq * t) + 0.3 * sin(4 * pi * noteFreq * t)) * decay;
    samples.add(s * 0.7);
  }

  final bytes = createWavBytes(samples, sampleRate);
  await File(path).writeAsBytes(bytes);
}

Future<void> generateAmbientWav(String path) async {
  const sampleRate = 44100;
  final duration = 4.0;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];

  final freqs = [220.0, 261.63, 329.63];

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final loopWindow = 0.5 * (1 - cos(2 * pi * t / duration));
    var s = 0.0;
    for (final f in freqs) {
      s += sin(2 * pi * f * t + 0.2 * sin(2 * pi * 0.5 * t));
    }
    s = (s / freqs.length) * loopWindow;
    samples.add(s * 0.4);
  }

  final bytes = createWavBytes(samples, sampleRate);
  await File(path).writeAsBytes(bytes);
}

Future<void> generateLottieCelebration(String path) async {
  final lottieMap = {
    "v": "5.5.7",
    "fr": 60,
    "ip": 0,
    "op": 90,
    "w": 300,
    "h": 300,
    "nm": "CelebrationConfetti",
    "ddd": 0,
    "assets": [],
    "layers": [
      {
        "ddd": 0,
        "ind": 1,
        "ty": 4,
        "nm": "Star Burst",
        "sr": 1,
        "ks": {
          "o": {
            "a": 1,
            "k": [
              {"t": 0, "s": [100]},
              {"t": 75, "s": [100]},
              {"t": 90, "s": [0]}
            ]
          },
          "r": {
            "a": 1,
            "k": [
              {"t": 0, "s": [0]},
              {"t": 90, "s": [180]}
            ]
          },
          "p": {
            "a": 0,
            "k": [150, 150, 0]
          },
          "a": {
            "a": 0,
            "k": [0, 0, 0]
          },
          "s": {
            "a": 1,
            "k": [
              {"t": 0, "s": [0, 0, 100]},
              {"t": 45, "s": [120, 120, 100]},
              {"t": 90, "s": [100, 100, 100]}
            ]
          }
        },
        "ao": 0,
        "shapes": [
          {
            "ty": "gr",
            "it": [
              {
                "ty": "sr",
                "sy": 1,
                "p": {"a": 0, "k": [0, 0]},
                "r": {"a": 0, "k": 0},
                "pt": {"a": 0, "k": 5},
                "ir": {"a": 0, "k": 25},
                "is": {"a": 0, "k": 0},
                "or": {"a": 0, "k": 60},
                "os": {"a": 0, "k": 0},
                "nm": "StarPath"
              },
              {
                "ty": "fl",
                "c": {
                  "a": 0,
                  "k": [1.0, 0.84, 0.0, 1.0]
                },
                "o": {"a": 0, "k": 100},
                "r": 1,
                "nm": "GoldFill"
              },
              {
                "ty": "tr",
                "p": {"a": 0, "k": [0, 0]},
                "a": {"a": 0, "k": [0, 0]},
                "s": {"a": 0, "k": [100, 100]},
                "r": {"a": 0, "k": 0},
                "o": {"a": 0, "k": 100}
              }
            ],
            "nm": "StarGroup"
          }
        ],
        "ip": 0,
        "op": 90,
        "st": 0,
        "bm": 0
      }
    ]
  };

  await File(path).writeAsString(jsonEncode(lottieMap));
}

/// Generates 120 handcrafted levels with increasing difficulty and verified solvability
Future<void> generate120Levels() async {
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
      colorCount = (lvl <= 70) ? 7 : 8;
    } else if (lvl <= 100) {
      colorCount = (lvl <= 90) ? 8 : 9;
    } else {
      colorCount = (lvl <= 110) ? 10 : 11;
    }

    final levelData = generateValidatedLevel(lvl, colorCount, emptyBottles);

    final filename = 'assets/levels/level_${lvl.toString().padLeft(3, '0')}.json';
    await File(filename).writeAsString(
      const JsonEncoder.withIndent('  ').convert(levelData),
    );
  }
}

Map<String, dynamic> generateValidatedLevel(int levelId, int colorCount, int emptyBottles) {
  var seed = 1000 + levelId * 53;

  while (true) {
    final rand = Random(seed);
    // Solved state: colorCount bottles with 4 segments of each color
    final bottles = List.generate(colorCount, (i) => List<int>.filled(4, i + 1, growable: true));
    for (var i = 0; i < emptyBottles; i++) {
      bottles.add(<int>[]);
    }

    // Scramble by performing reverse pours:
    // In reverse pour, we can take a segment from top of any bottle and put into any bottle that has space,
    // provided we avoid trivially undoing previous move immediately.
    final steps = 15 + (levelId * 2);
    int lastFrom = -1;
    int lastTo = -1;

    for (var s = 0; s < steps; s++) {
      final validSources = <int>[];
      for (var i = 0; i < bottles.length; i++) {
        if (bottles[i].isNotEmpty) validSources.add(i);
      }
      if (validSources.isEmpty) break;

      final from = validSources[rand.nextInt(validSources.length)];

      final validTargets = <int>[];
      for (var j = 0; j < bottles.length; j++) {
        if (j != from && bottles[j].length < 4) {
          if (!(from == lastTo && j == lastFrom)) {
            validTargets.add(j);
          }
        }
      }

      if (validTargets.isEmpty) continue;
      final to = validTargets[rand.nextInt(validTargets.length)];

      final val = bottles[from].removeLast();
      bottles[to].add(val);

      lastFrom = from;
      lastTo = to;
    }

    // Ensure not already solved
    var isAlreadySolved = true;
    for (final b in bottles) {
      if (b.isNotEmpty) {
        if (b.length != 4 || b.any((c) => c != b.first)) {
          isAlreadySolved = false;
          break;
        }
      }
    }

    // Ensure at least 1 empty bottle
    final currentEmpty = bottles.where((b) => b.isEmpty).length;

    if (!isAlreadySolved && currentEmpty >= 1) {
      // Quick BFS check to verify solvable
      if (isLevelSolvable(bottles)) {
        return {
          "id": levelId,
          "difficulty": getDifficultyLabel(levelId),
          "bottleCount": bottles.length,
          "emptyBottles": currentEmpty,
          "bottles": bottles,
        };
      }
    }

    seed += 7; // Try next seed
  }
}

/// Simple BFS solver to verify level solvability within search limit
bool isLevelSolvable(List<List<int>> initialBottles) {
  final queue = Queue<List<List<int>>>();
  final visited = <String>{};

  final startState = initialBottles.map((b) => List<int>.from(b)).toList();
  queue.add(startState);
  visited.add(encodeState(startState));

  var iterations = 0;
  const maxIterations = 8000;

  while (queue.isNotEmpty && iterations < maxIterations) {
    iterations++;
    final current = queue.removeFirst();

    if (isSolved(current)) return true;

    for (var i = 0; i < current.length; i++) {
      if (current[i].isEmpty) continue;
      final sourceColor = current[i].last;

      for (var j = 0; j < current.length; j++) {
        if (i == j) continue;
        if (current[j].length == 4) continue;

        if (current[j].isEmpty || current[j].last == sourceColor) {
          // Valid move! Create new state
          final nextState = current.map((b) => List<int>.from(b)).toList();
          final amount = min(
            countTopColor(current[i]),
            4 - current[j].length,
          );

          for (var k = 0; k < amount; k++) {
            nextState[j].add(nextState[i].removeLast());
          }

          final encoded = encodeState(nextState);
          if (!visited.contains(encoded)) {
            visited.add(encoded);
            queue.add(nextState);
          }
        }
      }
    }
  }

  return false;
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

bool isSolved(List<List<int>> state) {
  for (final b in state) {
    if (b.isEmpty) continue;
    if (b.length != 4) return false;
    final first = b.first;
    for (final c in b) {
      if (c != first) return false;
    }
  }
  return true;
}

String encodeState(List<List<int>> state) {
  // Sort canonical representations of bottles so bottle permutation doesn't duplicate
  final bottleStrings = state.map((b) => b.join(',')).toList()..sort();
  return bottleStrings.join('|');
}

String getDifficultyLabel(int level) {
  if (level <= 20) return "Easy";
  if (level <= 40) return "Easy+";
  if (level <= 60) return "Medium";
  if (level <= 80) return "Hard";
  if (level <= 100) return "Expert";
  return "Master";
}
