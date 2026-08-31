import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:stela_mobile/features/profile/domain/usecases/activate_streak_freeze_usecase.dart';
import 'package:stela_mobile/features/profile/domain/usecases/set_reminder_usecase.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isReminderEnabled = false,
    this.reminderHour = 8,
    this.streakFreezeActivated = false,
    this.isSavingReminder = false,
    this.isActivatingFreeze = false,
  });

  final bool isReminderEnabled;
  final int reminderHour;
  final bool streakFreezeActivated;
  final bool isSavingReminder;
  final bool isActivatingFreeze;

  DailyReminderPayload get payload => DailyReminderPayload(
        dailyReminderEnabled: isReminderEnabled,
        reminderHour: reminderHour,
      );

  SettingsState copyWith({
    bool? isReminderEnabled,
    int? reminderHour,
    bool? streakFreezeActivated,
    bool? isSavingReminder,
    bool? isActivatingFreeze,
  }) {
    return SettingsState(
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      streakFreezeActivated:
          streakFreezeActivated ?? this.streakFreezeActivated,
      isSavingReminder: isSavingReminder ?? this.isSavingReminder,
      isActivatingFreeze: isActivatingFreeze ?? this.isActivatingFreeze,
    );
  }

  @override
  List<Object?> get props => [
        isReminderEnabled,
        reminderHour,
        streakFreezeActivated,
        isSavingReminder,
        isActivatingFreeze,
      ];
}

sealed class SettingsEffect {
  const SettingsEffect();
}

final class SettingsErrorEffect extends SettingsEffect {
  const SettingsErrorEffect(this.message);
  final String message;
}

final class SettingsSuccessEffect extends SettingsEffect {
  const SettingsSuccessEffect(this.message);
  final Object message;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repo, this._prefsFuture)
      : super(const SettingsState()) {
    _loadLocalSettings();
  }

  final ProfileRepository _repo;
  final Future<SharedPreferences> _prefsFuture;
  final _effects = StreamController<SettingsEffect>.broadcast();

  Stream<SettingsEffect> get effects => _effects.stream;

  Future<void> _loadLocalSettings() async {
    final prefs = await _prefsFuture;
    emit(
      state.copyWith(
        isReminderEnabled: prefs.getBool(isReminderEnabledKey) ?? false,
        reminderHour: prefs.getInt(reminderHourKey) ?? 8,
      ),
    );
  }

  Future<void> setDailyReminderValue(bool enabled) async {
    var hour = state.reminderHour;
    if (enabled && hour < 0) {
      hour = 8;
    }

    emit(
      state.copyWith(
        isReminderEnabled: enabled,
        reminderHour: hour,
        isSavingReminder: true,
      ),
    );

    final prefs = await _prefsFuture;
    await prefs.setBool(isReminderEnabledKey, enabled);
    await prefs.setInt(reminderHourKey, hour);

    logg('Setting daily reminder: enabled=$enabled, hour=$hour');
    await _syncReminderToServer();
  }

  Future<void> setReminderHour(int hour) async {
    final clamped = hour.clamp(0, 23);
    emit(state.copyWith(reminderHour: clamped));

    final prefs = await _prefsFuture;
    await prefs.setInt(reminderHourKey, clamped);

    if (state.isReminderEnabled) {
      await _syncReminderToServer();
    }
  }

  Future<void> _syncReminderToServer() async {
    emit(state.copyWith(isSavingReminder: true));

    final result = await SetReminderUseCase(_repo, state.payload).invoke();
    final value = result.getOrElse((error) {
      emit(
        state.copyWith(
          isReminderEnabled: false,
          isSavingReminder: false,
        ),
      );
      _effects.add(SettingsErrorEffect(error.toString()));
      return null;
    });

    if (value != null) {
      _effects.add(SettingsSuccessEffect(value));
    }
    emit(state.copyWith(isSavingReminder: false));
  }

  Future<void> activateStreakFreeze(bool enabled) async {
    if (!enabled) {
      emit(state.copyWith(streakFreezeActivated: false));
      return;
    }

    if (state.isActivatingFreeze) return;
    emit(state.copyWith(isActivatingFreeze: true));

    final result = await ActivateStreakFreezeUseCase(_repo).invoke();
    final value = result.getOrElse((error) {
      emit(
        state.copyWith(
          streakFreezeActivated: false,
          isActivatingFreeze: false,
        ),
      );
      _effects.add(SettingsErrorEffect(error.toString()));
      return null;
    });

    if (value != null) {
      emit(
        state.copyWith(
          streakFreezeActivated: value.success,
          isActivatingFreeze: false,
        ),
      );
      _effects.add(SettingsSuccessEffect(value));
    } else {
      emit(state.copyWith(isActivatingFreeze: false));
    }
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

SettingsCubit createSettingsCubit() => SettingsCubit(
      getIt.get<ProfileRepository>(),
      getIt.getAsync<SharedPreferences>(),
    );
