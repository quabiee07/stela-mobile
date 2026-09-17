import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/features/library/data/services/stories_api_service.dart';
import 'package:stela_mobile/features/library/data/services/story_detail_store.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_content.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

@LazySingleton(as: StoriesRepository)
class StoriesRepositoryImpl implements StoriesRepository {
  StoriesRepositoryImpl(this._api, this._detailStore);

  final StoriesApiService _api;
  final StoryDetailStore _detailStore;

  /// Shared in-flight Future so Home + Library cold-start share one HTTP call.
  Future<ApiResult<List<StorySummary>>>? _storiesInFlight;

  /// Short-lived success cache to absorb back-to-back tab loads.
  ApiResult<List<StorySummary>>? _storiesCache;
  DateTime? _storiesCacheAt;
  static const _cacheTtl = Duration(seconds: 30);

  @visibleForTesting
  static bool isStoriesCacheFresh({
    required DateTime? cachedAt,
    required DateTime now,
    Duration ttl = _cacheTtl,
  }) {
    if (cachedAt == null) return false;
    return now.difference(cachedAt) < ttl;
  }

  final _detailMemory = <String, StoryDetail>{};
  final _detailInFlight = <String, Future<ApiResult<StoryDetail>>>{};

  @override
  Future<ApiResult<List<StorySummary>>> getStories({bool force = false}) async {
    if (!force &&
        _storiesCache != null &&
        _storiesCache!.isSuccess &&
        isStoriesCacheFresh(
          cachedAt: _storiesCacheAt,
          now: DateTime.now(),
        )) {
      return _storiesCache!;
    }

    final inFlight = _storiesInFlight;
    if (inFlight != null) return inFlight;

    final future = _fetchStories();
    _storiesInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_storiesInFlight, future)) {
        _storiesInFlight = null;
      }
    }
  }

  Future<ApiResult<List<StorySummary>>> _fetchStories() async {
    try {
      final result = await _api.getStories();
      final mapped = ApiResult.success(
        result.map((story) => story.toDto()).toList(),
      );
      _storiesCache = mapped;
      _storiesCacheAt = DateTime.now();
      return mapped;
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<StoryDetail>> getStoryDetail(
    String storyId, {
    bool force = false,
  }) async {
    if (!force) {
      final memory = _detailMemory[storyId];
      if (memory != null) return ApiResult.success(memory);

      final stored = await _detailStore.read(storyId);
      if (stored != null) {
        _detailMemory[storyId] = stored;
        return ApiResult.success(stored);
      }
    }

    final existing = _detailInFlight[storyId];
    if (existing != null) return existing;

    final future = _fetchStoryDetail(storyId);
    _detailInFlight[storyId] = future;
    try {
      return await future;
    } finally {
      if (identical(_detailInFlight[storyId], future)) {
        _detailInFlight.remove(storyId);
      }
    }
  }

  Future<ApiResult<StoryDetail>> _fetchStoryDetail(String storyId) async {
    try {
      final result = await _api.getStoryDetail(storyId: storyId);
      final detail = result.toDto();
      _detailMemory[storyId] = detail;
      await _detailStore.write(detail);
      return ApiResult.success(detail);
    } catch (e) {
      // Prefer a previously opened description over a hard failure.
      final fallback =
          _detailMemory[storyId] ?? await _detailStore.read(storyId);
      if (fallback != null) {
        _detailMemory[storyId] = fallback;
        return ApiResult.success(fallback);
      }
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<ChapterContent>> getChapterContent({
    required String storyId,
    required String chapterId,
  }) async {
    try {
      final result = await _api.getChapterContent(
        storyId: storyId,
        chapterId: chapterId,
      );
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }
}
