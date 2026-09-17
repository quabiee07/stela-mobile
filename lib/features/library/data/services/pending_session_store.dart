import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_request_dto.dart';

/// Durable queue of session logs that failed to reach the API.
@lazySingleton
class PendingSessionStore {
  PendingSessionStore() : _prefsFuture = getIt.getAsync<SharedPreferences>();

  PendingSessionStore.test({required Future<SharedPreferences> prefs})
      : _prefsFuture = prefs;

  static const _key = 'pending_session_logs_v1';

  final Future<SharedPreferences> _prefsFuture;

  Future<List<SessionLogRequestDto>> peekAll() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => SessionLogRequestDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueue(SessionLogRequestDto payload) async {
    final pending = await peekAll();
    pending.removeWhere((item) => item.sessionId == payload.sessionId);
    pending.add(payload);
    await _write(pending);
  }

  Future<void> remove(String sessionId) async {
    final pending = await peekAll();
    pending.removeWhere((item) => item.sessionId == sessionId);
    await _write(pending);
  }

  Future<void> _write(List<SessionLogRequestDto> pending) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _key,
      jsonEncode(pending.map((item) => item.toJson()).toList()),
    );
  }
}
