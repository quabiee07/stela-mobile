import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

/// Remembers which calendar day already showed [StreakCelebrationScreen]
/// so first-open and post-session rewards never double-fire the same day.
class StreakCelebrationStore {
  StreakCelebrationStore({SharedPreferences? prefs})
      : _prefsFuture = prefs != null
            ? Future.value(prefs)
            : getIt.getAsync<SharedPreferences>();

  static const storageKey = 'streak_celebration_shown_day_v2';

  final Future<SharedPreferences> _prefsFuture;

  Future<String?> shownDayKey() async {
    final prefs = await _prefsFuture;
    return prefs.getString(storageKey);
  }

  Future<bool> wasShownToday([DateTime? now]) async {
    final shown = await shownDayKey();
    return shown == GamificationDisplay.dayKey(now);
  }

  Future<void> markShownToday([DateTime? now]) async {
    final prefs = await _prefsFuture;
    await prefs.setString(storageKey, GamificationDisplay.dayKey(now));
  }
}
