import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreController extends GetxController {
  static const String _winsKey = 'score_wins';
  static const String _bestMovesKey = 'score_best_moves';
  static const String _bestTimeKey = 'score_best_time';

  final Map<int, int> _bestMoves = <int, int>{};
  final Map<int, int> _bestTimeInSeconds = <int, int>{};
  final Map<int, int> _wins = <int, int>{};

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadScores());
  }

  int winsOf(int size) => _wins[size] ?? 0;
  int? bestMovesOf(int size) => _bestMoves[size];
  int? bestTimeOf(int size) => _bestTimeInSeconds[size];

  void recordWin({required int size, required int moves, required int elapsedSeconds}) {
    _wins[size] = winsOf(size) + 1;

    final int? bestMoves = _bestMoves[size];
    if (bestMoves == null || moves < bestMoves) {
      _bestMoves[size] = moves;
    }

    final int? bestTime = _bestTimeInSeconds[size];
    if (bestTime == null || elapsedSeconds < bestTime) {
      _bestTimeInSeconds[size] = elapsedSeconds;
    }
    unawaited(_saveScores());
    update();
  }

  Future<void> _loadScores() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      _wins
        ..clear()
        ..addAll(_decodeMap(prefs.getString(_winsKey)));
      _bestMoves
        ..clear()
        ..addAll(_decodeMap(prefs.getString(_bestMovesKey)));
      _bestTimeInSeconds
        ..clear()
        ..addAll(_decodeMap(prefs.getString(_bestTimeKey)));

      update();
    } catch (_) {
      // Keep score feature usable even if local persistence is unavailable.
    }
  }

  Future<void> _saveScores() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_winsKey, jsonEncode(_wins));
      await prefs.setString(_bestMovesKey, jsonEncode(_bestMoves));
      await prefs.setString(_bestTimeKey, jsonEncode(_bestTimeInSeconds));
    } catch (_) {
      // Ignore persistence failures and keep the in-memory score state.
    }
  }

  Map<int, int> _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <int, int>{};
    }

    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <int, int>{};
    }

    final Map<int, int> result = <int, int>{};
    decoded.forEach((String key, dynamic value) {
      final int? parsedKey = int.tryParse(key);
      final int? parsedValue = value is int ? value : int.tryParse(value.toString());
      if (parsedKey != null && parsedValue != null) {
        result[parsedKey] = parsedValue;
      }
    });
    return result;
  }
}