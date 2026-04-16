import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../screens/home_page.dart';
import 'score_controller.dart';
import 'settings_controller.dart';
import 'sound_controller.dart';

class PuzzleController extends GetxController {
  PuzzleController({required this.size});

  final int size;
  final Random _random = Random();
  final ScoreController _scoreController = Get.find<ScoreController>();
  final SettingsController _settingsController = Get.find<SettingsController>();
  final SoundController _soundController = Get.find<SoundController>();
  Timer? _ticker;
  bool _dialogOpen = false;

  late List<int> tiles;
  int moves = 0;
  int elapsedSeconds = 0;
  bool solved = false;

  int get emptyIndex => tiles.indexOf(0);
  String get timeText {
    final int minPart = elapsedSeconds ~/ 60;
    final int secPart = elapsedSeconds % 60;
    return '${minPart.toString().padLeft(2, '0')}:${secPart.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _startNewGame();
  }

  void _startNewGame() {
    tiles = List<int>.generate(size * size, (int index) => index);
    _shuffleUntilSolvable();
    moves = 0;
    elapsedSeconds = 0;
    solved = false;
    _dialogOpen = false;
    _startTimer();
    update(<Object>['board', 'stats']);
  }

  void restart() {
    _startNewGame();
  }

  void slideTile(int index) {
    if (solved || !_canSlide(index)) {
      return;
    }

    if (_settingsController.soundEnabled) {
      HapticFeedback.selectionClick();
      unawaited(_soundController.playMove());
    }

    final int empty = emptyIndex;
    final int value = tiles[index];
    tiles[index] = 0;
    tiles[empty] = value;
    moves++;

    if (_isSolved()) {
      solved = true;
      _ticker?.cancel();
      _scoreController.recordWin(
        size: size,
        moves: moves,
        elapsedSeconds: elapsedSeconds,
      );
      if (_settingsController.soundEnabled) {
        HapticFeedback.heavyImpact();
        unawaited(_soundController.playWin());
      }
      _showPremiumWinDialog();
    }

    update(<Object>['board', 'stats']);
  }

  void _showPremiumWinDialog() {
    if (_dialogOpen) {
      return;
    }
    _dialogOpen = true;

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF0B7285), Color(0xFF0C8599)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 46),
              const SizedBox(height: 10),
              const Text(
                'Champion Win!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Moves: $moves  |  Time: $timeText',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60),
                      ),
                      onPressed: () {
                        _dialogOpen = false;
                        Get.back<void>();
                        Get.offAll(() => const HomePage());
                      },
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        _dialogOpen = false;
                        Get.back<void>();
                        restart();
                      },
                      child: const Text('Reload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!solved) {
        elapsedSeconds++;
        update(<Object>['stats']);
      }
    });
  }

  bool _canSlide(int index) {
    final int empty = emptyIndex;
    final int row = index ~/ size;
    final int col = index % size;
    final int emptyRow = empty ~/ size;
    final int emptyCol = empty % size;
    return (row - emptyRow).abs() + (col - emptyCol).abs() == 1;
  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) {
        return false;
      }
    }
    return tiles.last == 0;
  }

  void _shuffleUntilSolvable() {
    do {
      tiles.shuffle(_random);
    } while (!_isSolvable(tiles) || _isSolved());
  }

  bool _isSolvable(List<int> currentTiles) {
    final List<int> numbers = currentTiles.where((int n) => n != 0).toList();
    int inversions = 0;
    for (int i = 0; i < numbers.length; i++) {
      for (int j = i + 1; j < numbers.length; j++) {
        if (numbers[i] > numbers[j]) {
          inversions++;
        }
      }
    }

    if (size.isOdd) {
      return inversions.isEven;
    }

    final int blankRowFromBottom = size - (currentTiles.indexOf(0) ~/ size);
    if (blankRowFromBottom.isEven) {
      return inversions.isOdd;
    }
    return inversions.isEven;
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}