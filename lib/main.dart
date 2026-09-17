import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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
  } catch (_) {
    // Optional local secrets. Missing .env must not block startup.
  }

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  if (firebaseReady) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
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
