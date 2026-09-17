import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_request_dto.dart';
import 'package:stela_mobile/features/library/data/services/pending_session_store.dart';
import 'package:stela_mobile/features/library/data/services/session_id_store.dart';
import 'package:stela_mobile/features/library/data/services/session_service.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart';

@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(
    this._sessionService,
    this._sessionIdStore,
    this._pendingSessionStore,
  ) : _firebaseAuth = FirebaseAuth.instance;

  final SessionService _sessionService;
  final SessionIdStore _sessionIdStore;
  final PendingSessionStore _pendingSessionStore;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<ApiResult<SessionLogResult>> logSession({
    required String bookId,
    required String bookTitle,
    required String genre,
    required String chapterId,
    required bool isAudioSession,
    required bool isBookComplete,
    required double speedMultiplier,
  }) async {
    final sessionId = await _sessionIdStore.getOrCreate(
      bookId: bookId,
      chapterId: chapterId,
    );

    final requestPayload = SessionLogRequestDto(
      sessionId: sessionId,
      bookId: bookId,
      bookTitle: bookTitle,
      genre: genre,
      chapterId: chapterId,
      isAudioSession: isAudioSession,
      isBookComplete: isBookComplete,
      speedMultiplier: speedMultiplier,
    );

    if (_firebaseAuth.currentUser == null) {
      await _pendingSessionStore.enqueue(requestPayload);
      return ApiResult.failure(const UnauthorizedFailure());
    }

    await flushPending();

    try {
      final response = await _sessionService.logSession(
        payload: requestPayload,
      );

      final result = response.toDto();
      if (result.success) {
        await _markDelivered(requestPayload);
      } else {
        await _pendingSessionStore.enqueue(requestPayload);
      }

      return ApiResult.success(result);
    } catch (e) {
      await _pendingSessionStore.enqueue(requestPayload);
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<void> flushPending() async {
    if (_firebaseAuth.currentUser == null) return;

    final pending = await _pendingSessionStore.peekAll();
    for (final payload in pending) {
      try {
        final response = await _sessionService.logSession(payload: payload);
        if (response.success) {
          await _markDelivered(payload);
        }
      } catch (_) {
        // Keep queued for a later attempt.
      }
    }
  }

  Future<void> _markDelivered(SessionLogRequestDto payload) async {
    await _sessionIdStore.clear(
      bookId: payload.bookId,
      chapterId: payload.chapterId,
    );
    await _pendingSessionStore.remove(payload.sessionId);
  }
}
