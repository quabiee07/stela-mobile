import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

class SynthesizeStoryUseCase
    implements UseCase<SynthesizedAudio, SynthesizeStoryPayload> {
  final LibraryRepository repository;
  final SynthesizeStoryPayload payload;

  SynthesizeStoryUseCase(this.repository, this.payload);

  @override
  Future<ApiResult<SynthesizedAudio>> invoke() async {
    return repository.synthesize(param.text, param.voiceId);
  }

  @override
  SynthesizeStoryPayload get param => payload;
}

class SynthesizeStoryPayload {
  final String text;
  final String voiceId;
  const SynthesizeStoryPayload({required this.text, required this.voiceId});
}
