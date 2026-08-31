import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/app.dart';
import 'package:stela_mobile/features/library/presentation/manager/playback_media_service.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/env/.env');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));
  await configureDependencies();

  try {
    await PlaybackMediaService.init();
    getIt.get<StoryPlaybackCubit>().attachMediaHandler(
          PlaybackMediaService.handler!,
        );
  } catch (e) {
    debugPrint('Playback media service init failed: $e');
  }

  runApp(const StelaApp());
}
