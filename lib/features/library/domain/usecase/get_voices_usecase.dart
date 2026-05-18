
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/voices.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

class GetVoicesUseCase implements UseCase<List<VoiceModel>, void> {
  late final LibraryRepository repository;

  GetVoicesUseCase(this.repository);

  @override
  Future<ApiResult<List<VoiceModel>>> invoke() async {
    return repository.getAvailableVoices();
  }

  @override
  void get param => throw UnimplementedError();
}
