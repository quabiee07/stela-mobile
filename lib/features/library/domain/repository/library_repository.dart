import 'dart:typed_data';

import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/library/domain/models/voices.dart';

abstract class LibraryRepository {
  Future<ApiResult<Uint8List>> synthesize(
    String text,
    String voiceId
  );
  Future<ApiResult<List<VoiceModel>>> getAvailableVoices();
}
