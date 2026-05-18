import 'dart:typed_data';

import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

class SynthesizeStoryUseCase implements UseCase<Uint8List, SynthesizeStoryPayload> {
  late final LibraryRepository repository;
  late final SynthesizeStoryPayload payload;

  SynthesizeStoryUseCase(this.repository, this.payload);

  @override
  Future<ApiResult<Uint8List>> invoke() async {
   return repository.synthesize(param.voiceId, param.text);
   
  }

   @override
  SynthesizeStoryPayload get param => payload;
}

class SynthesizeStoryPayload {
  final String text;
  final String voiceId;
  const SynthesizeStoryPayload({required this.text, required this.voiceId});
}
