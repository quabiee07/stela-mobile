import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Local/dev secrets. Production TTS must be proxied by the Stela API —
/// never ship a paid vendor key in the client binary.
class AppSecrets {
  const AppSecrets._();

  static String? elevenLabsApiKey() {
    const defined = String.fromEnvironment('ELEVENLABS_API_KEY');
    if (defined.isNotEmpty) return defined;
    final env = dotenv.env['ELEVENLABS_API_KEY']?.trim();
    if (env != null && env.isNotEmpty) return env;
    return null;
  }

  static String? googleServerClientId() {
    const defined = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (defined.isNotEmpty) return defined;
    final env = dotenv.env['SERVER_ID']?.trim();
    if (env != null && env.isNotEmpty) return env;
    return null;
  }
}
