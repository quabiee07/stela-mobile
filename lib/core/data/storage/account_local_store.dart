import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/library/data/services/reading_progress_service.dart';
import 'package:stela_mobile/features/library/data/services/voice_preference_store.dart';
import 'package:stela_mobile/features/profile/data/services/weekly_activity_store.dart';

/// Keeps local account data keyed by Firebase uid so:
/// - logout clears the *active* session
/// - logging back into the *same* account restores that account's local data
/// - a *different* account does not inherit the previous account's data
class AccountLocalStore {
  AccountLocalStore({Future<SharedPreferences>? prefs})
      : _prefsFuture = prefs ?? getIt.getAsync<SharedPreferences>();

  static const lastAccountUidKey = 'last_account_uid';

  static const _activeVoiceKey = VoicePreferenceStore.voiceIdKey;
  static const _activeWeeklyKey = WeeklyActivityStore.storageKey;
  static const _activeReadingKey = ReadingProgressService.storageKey;
  // Keep in sync with ReadingPreferencesCubit keys.
  static const _activeTextSpeedKey = 'reading_text_speed';
  static const _activeTextSizeKey = 'reading_text_size_scale';

  final Future<SharedPreferences> _prefsFuture;

  static String onboardedKeyFor(String uid) => '${isOnboardedKey}_$uid';
  static String userCacheKeyFor(String uid) => '${userKey}_$uid';
  static String voiceKeyFor(String uid) => '${_activeVoiceKey}_$uid';
  static String weeklyKeyFor(String uid) => '${_activeWeeklyKey}_$uid';
  static String readingKeyFor(String uid) => '${_activeReadingKey}_$uid';
  static String textSpeedKeyFor(String uid) => '${_activeTextSpeedKey}_$uid';
  static String textSizeKeyFor(String uid) => '${_activeTextSizeKey}_$uid';

  /// Call before Firebase sign-out. Snapshots active prefs under [uid], then
  /// clears only the active session keys (not the per-uid snapshots).
  Future<void> clearActiveSession({String? uid}) async {
    final prefs = await _prefsFuture;
    final resolvedUid = uid ??
        cachedUser?.id ??
        FirebaseAuth.instance.currentUser?.uid;

    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      await prefs.setString(lastAccountUidKey, resolvedUid);
      await _snapshotActiveToUid(prefs, resolvedUid);
    }

    await prefs.remove(userKey);
    await prefs.remove(isOnboardedKey);
    await prefs.remove(tokenKey);
    await prefs.remove(_activeVoiceKey);
    await prefs.remove(_activeWeeklyKey);
    await prefs.remove(_activeReadingKey);
    await prefs.remove(_activeTextSpeedKey);
    await prefs.remove(_activeTextSizeKey);
    cachedUser = null;
  }

  /// Call after Firebase auth succeeds. Restores this uid's snapshot when it
  /// matches the last account; otherwise leaves active prefs empty for a fresh
  /// profile sync / setup.
  Future<void> bindAccount(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await _prefsFuture;
    final lastUid = prefs.getString(lastAccountUidKey);
    final isSameAccount = lastUid == null || lastUid == uid;

    await prefs.setString(lastAccountUidKey, uid);

    if (isSameAccount) {
      await _restoreUidToActive(prefs, uid);
    } else {
      // Different account — do not restore previous uid data into active keys.
      await prefs.remove(userKey);
      await prefs.remove(isOnboardedKey);
      await prefs.remove(_activeVoiceKey);
      await prefs.remove(_activeWeeklyKey);
      await prefs.remove(_activeReadingKey);
      await prefs.remove(_activeTextSpeedKey);
      await prefs.remove(_activeTextSizeKey);
      cachedUser = null;
    }
  }

  Future<void> markOnboarded(String uid, {required bool onboarded}) async {
    final prefs = await _prefsFuture;
    await prefs.setBool(isOnboardedKey, onboarded);
    await prefs.setBool(onboardedKeyFor(uid), onboarded);
    await prefs.setString(lastAccountUidKey, uid);
  }

  Future<bool> isOnboardedFor(String uid) async {
    final prefs = await _prefsFuture;
    return prefs.getBool(onboardedKeyFor(uid)) ??
        prefs.getBool(isOnboardedKey) ??
        false;
  }

  Future<void> _snapshotActiveToUid(SharedPreferences prefs, String uid) async {
    final onboarded = prefs.getBool(isOnboardedKey);
    if (onboarded != null) {
      await prefs.setBool(onboardedKeyFor(uid), onboarded);
    }

    final userJson = prefs.getString(userKey);
    if (userJson != null && userJson.isNotEmpty) {
      await prefs.setString(userCacheKeyFor(uid), userJson);
    }

    final voice = prefs.getString(_activeVoiceKey);
    if (voice != null && voice.isNotEmpty) {
      await prefs.setString(voiceKeyFor(uid), voice);
    }

    final weekly = prefs.getString(_activeWeeklyKey);
    if (weekly != null && weekly.isNotEmpty) {
      await prefs.setString(weeklyKeyFor(uid), weekly);
    }

    final reading = prefs.getString(_activeReadingKey);
    if (reading != null && reading.isNotEmpty) {
      await prefs.setString(readingKeyFor(uid), reading);
    }

    final textSpeed = prefs.getDouble(_activeTextSpeedKey);
    if (textSpeed != null) {
      await prefs.setDouble(textSpeedKeyFor(uid), textSpeed);
    }

    final textSize = prefs.getDouble(_activeTextSizeKey);
    if (textSize != null) {
      await prefs.setDouble(textSizeKeyFor(uid), textSize);
    }
  }

  Future<void> _restoreUidToActive(SharedPreferences prefs, String uid) async {
    final onboarded = prefs.getBool(onboardedKeyFor(uid));
    if (onboarded != null) {
      await prefs.setBool(isOnboardedKey, onboarded);
    }

    final userJson = prefs.getString(userCacheKeyFor(uid));
    if (userJson != null && userJson.isNotEmpty) {
      await prefs.setString(userKey, userJson);
    }

    final voice = prefs.getString(voiceKeyFor(uid));
    if (voice != null && voice.isNotEmpty) {
      await prefs.setString(_activeVoiceKey, voice);
    }

    final weekly = prefs.getString(weeklyKeyFor(uid));
    if (weekly != null && weekly.isNotEmpty) {
      await prefs.setString(_activeWeeklyKey, weekly);
    }

    final reading = prefs.getString(readingKeyFor(uid));
    if (reading != null && reading.isNotEmpty) {
      await prefs.setString(_activeReadingKey, reading);
    }

    final textSpeed = prefs.getDouble(textSpeedKeyFor(uid));
    if (textSpeed != null) {
      await prefs.setDouble(_activeTextSpeedKey, textSpeed);
    } else {
      await prefs.remove(_activeTextSpeedKey);
    }

    final textSize = prefs.getDouble(textSizeKeyFor(uid));
    if (textSize != null) {
      await prefs.setDouble(_activeTextSizeKey, textSize);
    } else {
      await prefs.remove(_activeTextSizeKey);
    }
  }
}
