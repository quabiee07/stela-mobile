import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

/// Local Mon–Sun session counts for the streak bar chart.
/// The streak API does not return a weekly series, so we accumulate these on
/// successful [POST /sessions/log] responses.
class WeeklyActivityStore {
  WeeklyActivityStore({SharedPreferences? prefs})
      : _prefsFuture = prefs != null
            ? Future.value(prefs)
            : getIt.getAsync<SharedPreferences>();

  static const storageKey = 'streak_week_session_counts_v1';

  final Future<SharedPreferences> _prefsFuture;

  Future<Map<String, int>> load() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, int>> incrementToday() async {
    final counts = await load();
    final key = GamificationDisplay.dayKey();
    counts[key] = (counts[key] ?? 0) + 1;
    await _persist(counts);
    return counts;
  }

  Future<void> _persist(Map<String, int> counts) async {
    // Keep only recent days so storage stays small.
    final cutoff = DateTime.now().subtract(const Duration(days: 45));
    counts.removeWhere((key, _) {
      final date = DateTime.tryParse(key);
      return date == null || date.isBefore(cutoff);
    });

    final prefs = await _prefsFuture;
    await prefs.setString(storageKey, jsonEncode(counts));
  }
}
