import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';

abstract class SessionRepository {
  Future<ApiResult<SessionLogResult>> logSession({
    required String bookId,
    required String bookTitle,
    required String genre,
    required String chapterId,
    required bool isAudioSession,
    required bool isBookComplete,
    required double speedMultiplier,
  });
}
