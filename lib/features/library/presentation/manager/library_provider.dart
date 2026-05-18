import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';
import 'package:just_audio/just_audio.dart';

class LibraryProvider extends CustomProvider{
  final _repo = getIt.get<LibraryRepository>();
  final _player = AudioPlayer();       
  
}