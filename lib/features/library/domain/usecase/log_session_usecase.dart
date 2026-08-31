import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart';

class LogSessionUseCase implements UseCase<SessionLogResult, LogSessionParams> {
  final SessionRepository _repository;

  LogSessionUseCase(this._repository);

  @override
  Future<ApiResult<SessionLogResult>> invoke() async {
    return _repository.logSession(
      bookId: param.bookId,
      bookTitle: param.bookTitle,
      genre: param.genre,
      chapterId: param.chapterId,
      isAudioSession: param.isAudioSession,
      isBookComplete: param.isBookComplete,
      speedMultiplier: param.speedMultiplier,
    );
  }

  @override
  late LogSessionParams param;
}

class LogSessionParams {
  final String bookId;
  final String bookTitle;
  final String genre;
  final String chapterId;
  final bool isAudioSession;
  final bool isBookComplete;
  final double speedMultiplier;

  LogSessionParams({
    required this.bookId,
    required this.bookTitle,
    required this.genre,
    required this.chapterId,
    required this.isAudioSession,
    required this.isBookComplete,
    required this.speedMultiplier,
  });
}
