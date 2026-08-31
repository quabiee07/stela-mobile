import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';

class ReadingPreferencesState extends Equatable {
  const ReadingPreferencesState({
    this.textSpeed = 1.0,
    this.textSizeScale = 0.5,
  });

  /// Playback / session speed. Allowed: 1.0, 1.5, 2.0 (API also allows 1.25).
  final double textSpeed;

  /// 0–1 slider position mapped to lyric font size.
  final double textSizeScale;

  static const speedOptions = [1.0, 1.5, 2.0];
  static const minFontSize = 16.0;
  static const maxFontSize = 28.0;
  static const defaultFontSize = 20.0;

  double get lyricFontSize =>
      minFontSize + textSizeScale * (maxFontSize - minFontSize);

  int get speedIndex {
    final index = speedOptions.indexOf(textSpeed);
    return index >= 0 ? index : 0;
  }

  ReadingPreferencesState copyWith({
    double? textSpeed,
    double? textSizeScale,
  }) {
    return ReadingPreferencesState(
      textSpeed: textSpeed ?? this.textSpeed,
      textSizeScale: textSizeScale ?? this.textSizeScale,
    );
  }

  @override
  List<Object?> get props => [textSpeed, textSizeScale];
}

@lazySingleton
class ReadingPreferencesCubit extends Cubit<ReadingPreferencesState> {
  ReadingPreferencesCubit() : super(const ReadingPreferencesState()) {
    _load();
  }

  static const textSpeedKey = 'reading_text_speed';
  static const textSizeScaleKey = 'reading_text_size_scale';

  Future<SharedPreferences> get _prefs => getIt.getAsync<SharedPreferences>();

  Future<void> reload() => _load();

  Future<void> _load() async {
    final prefs = await _prefs;
    final speed = prefs.getDouble(textSpeedKey) ?? 1.0;
    final sizeScale = prefs.getDouble(textSizeScaleKey) ?? 0.5;
    emit(
      ReadingPreferencesState(
        textSpeed: _normalizeSpeed(speed),
        textSizeScale: sizeScale.clamp(0.0, 1.0),
      ),
    );
  }

  double _normalizeSpeed(double speed) {
    if (ReadingPreferencesState.speedOptions.contains(speed)) return speed;
    // Snap to nearest allowed option.
    return ReadingPreferencesState.speedOptions.reduce(
      (a, b) => (a - speed).abs() <= (b - speed).abs() ? a : b,
    );
  }

  Future<void> setTextSpeed(double speed) async {
    final normalized = _normalizeSpeed(speed);
    emit(state.copyWith(textSpeed: normalized));
    final prefs = await _prefs;
    await prefs.setDouble(textSpeedKey, normalized);
  }

  Future<void> setTextSpeedIndex(int index) async {
    final clamped = index.clamp(0, ReadingPreferencesState.speedOptions.length - 1);
    await setTextSpeed(ReadingPreferencesState.speedOptions[clamped]);
  }

  Future<void> setTextSizeScale(double scale) async {
    final clamped = scale.clamp(0.0, 1.0);
    emit(state.copyWith(textSizeScale: clamped));
    final prefs = await _prefs;
    await prefs.setDouble(textSizeScaleKey, clamped);
  }
}
