import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';

class ReadingProgressService {
  static const storageKey = 'reading_progress';

  Future<List<ReadingProgress>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    final all = decoded
        .map((item) => ReadingProgress.fromJson(item as Map<String, dynamic>))
        .toList();
    final inProgress = all.where((item) => !item.isComplete).toList();

    if (inProgress.length != all.length) {
      inProgress.sort((a, b) => b.lastReadAtMs.compareTo(a.lastReadAtMs));
      await prefs.setString(
        storageKey,
        jsonEncode(inProgress.map((item) => item.toJson()).toList()),
      );
      return inProgress;
    }

    return inProgress
      ..sort((a, b) => b.lastReadAtMs.compareTo(a.lastReadAtMs));
  }

  Future<void> save(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _readAllRaw(prefs);
    existing.removeWhere((item) => item.storyId == progress.storyId);

    if (!progress.isComplete) {
      existing.add(progress);
    }

    existing.sort((a, b) => b.lastReadAtMs.compareTo(a.lastReadAtMs));
    await prefs.setString(
      storageKey,
      jsonEncode(existing.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> markComplete(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _readAllRaw(prefs);
    existing.removeWhere((item) => item.storyId == storyId);
    await prefs.setString(
      storageKey,
      jsonEncode(existing.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<ReadingProgress>> _readAllRaw(SharedPreferences prefs) async {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ReadingProgress.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
