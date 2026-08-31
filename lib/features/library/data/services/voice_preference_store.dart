import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/domain/models/narrator_voice.dart';

/// Persists the user's chosen narrator voice (non-secret preference).
@lazySingleton
class VoicePreferenceStore {
  VoicePreferenceStore() : _prefsFuture = getIt.getAsync<SharedPreferences>();

  static const voiceIdKey = 'narrator_voice_id';

  final Future<SharedPreferences> _prefsFuture;

  Future<String> getSelectedVoiceId() async {
    final prefs = await _prefsFuture;
    final stored = prefs.getString(voiceIdKey);
    if (stored != null &&
        stored.isNotEmpty &&
        NarratorVoiceCatalog.findById(stored) != null) {
      return stored;
    }
    return NarratorVoiceCatalog.defaultVoiceId;
  }

  Future<NarratorVoice> getSelectedVoice() async {
    final id = await getSelectedVoiceId();
    return NarratorVoiceCatalog.findById(id) ??
        NarratorVoiceCatalog.defaultVoice;
  }

  Future<void> setSelectedVoiceId(String voiceId) async {
    final prefs = await _prefsFuture;
    await prefs.setString(voiceIdKey, voiceId);
  }
}
