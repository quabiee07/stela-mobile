import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_request_dto.dart';
import 'package:stela_mobile/features/library/data/services/session_id_store.dart';
import 'package:stela_mobile/features/library/data/services/session_service.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart';

@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._sessionService, this._sessionIdStore);

  final SessionService _sessionService;
  final SessionIdStore _sessionIdStore;
  final _firebaseAuth = FirebaseAuth.instance;

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
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return ApiResult.failure(const UnauthorizedFailure());
      }

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

      final response = await _sessionService.logSession(
        payload: requestPayload,
      );

      final result = response.toDto();
      if (result.success) {
        await _sessionIdStore.clear(bookId: bookId, chapterId: chapterId);
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }
}
