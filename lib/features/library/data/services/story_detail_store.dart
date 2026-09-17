import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/data/dto/story_detail_dto.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';

/// Persists story descriptions the user has opened so revisits skip the network.
@lazySingleton
class StoryDetailStore {
  StoryDetailStore() : _prefsFuture = getIt.getAsync<SharedPreferences>();

  StoryDetailStore.test({required Future<SharedPreferences> prefs})
    : _prefsFuture = prefs;

  static const storageKey = 'story_detail_cache_v1';
  static const _maxEntries = 40;

  final Future<SharedPreferences> _prefsFuture;
  Map<String, StoryDetail>? _memory;

  Future<StoryDetail?> read(String storyId) async {
    final cache = await _ensureLoaded();
    return cache[storyId];
  }

  Future<void> write(StoryDetail detail) async {
    final cache = await _ensureLoaded();
    cache.remove(detail.storyId);
    cache[detail.storyId] = detail;

    while (cache.length > _maxEntries) {
      cache.remove(cache.keys.first);
    }

    await _persist(cache);
  }

  Future<Map<String, StoryDetail>> _ensureLoaded() async {
    if (_memory != null) return _memory!;

    final prefs = await _prefsFuture;
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _memory = <String, StoryDetail>{};
      return _memory!;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = <String, StoryDetail>{};
      for (final entry in decoded.entries) {
        final json = entry.value;
        if (json is! Map<String, dynamic>) continue;
        loaded[entry.key] = StoryDetailDto.fromJson(json).toDto();
      }
      _memory = loaded;
    } catch (_) {
      _memory = <String, StoryDetail>{};
    }
    return _memory!;
  }

  Future<void> _persist(Map<String, StoryDetail> cache) async {
    final encoded = <String, dynamic>{};
    for (final entry in cache.entries) {
      encoded[entry.key] = StoryDetailDto.fromDomain(entry.value).toJson();
    }
    final prefs = await _prefsFuture;
    await prefs.setString(storageKey, jsonEncode(encoded));
  }
}
