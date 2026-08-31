import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:uuid/uuid.dart';

/// Persists session UUIDs so retries after network failure stay idempotent.
@lazySingleton
class SessionIdStore {
  SessionIdStore()
      : _prefsFuture = getIt.getAsync<SharedPreferences>(),
        _uuid = const Uuid();

  final Future<SharedPreferences> _prefsFuture;
  final Uuid _uuid;

  String _key(String bookId, String chapterId) =>
      'session_id_${bookId}_$chapterId';

  Future<String> getOrCreate({
    required String bookId,
    required String chapterId,
  }) async {
    final prefs = await _prefsFuture;
    final key = _key(bookId, chapterId);
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;

    final sessionId = _uuid.v4();
    await prefs.setString(key, sessionId);
    return sessionId;
  }

  Future<void> clear({
    required String bookId,
    required String chapterId,
  }) async {
    final prefs = await _prefsFuture;
    await prefs.remove(_key(bookId, chapterId));
  }
}
