import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/data/storage/account_local_store.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/features/auth/domain/models/user_profile.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

class AccountState extends Equatable {
  const AccountState({
    this.isLoggingOut = false,
    this.isLoadingProfile = false,
    this.name = '',
    this.avatarUrl = '',
    this.title = '',
    this.email = '',
  });

  final bool isLoggingOut;
  final bool isLoadingProfile;
  final String name;
  final String avatarUrl;
  final String title;
  final String email;

  AccountState copyWith({
    bool? isLoggingOut,
    bool? isLoadingProfile,
    String? name,
    String? avatarUrl,
    String? title,
    String? email,
  }) {
    return AccountState(
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
        isLoggingOut,
        isLoadingProfile,
        name,
        avatarUrl,
        title,
        email,
      ];
}

sealed class ProfileEffect {
  const ProfileEffect();
}

final class ProfileErrorEffect extends ProfileEffect {
  const ProfileErrorEffect(this.message);
  final String message;
}

final class ProfileLoggedOutEffect extends ProfileEffect {
  const ProfileLoggedOutEffect();
}

@lazySingleton
class ProfileCubit extends Cubit<AccountState> {
  ProfileCubit(this._authRepo)
      : _accountLocal = AccountLocalStore(),
        super(const AccountState()) {
    hydrateFromCache();
  }

  final AuthRepository _authRepo;
  final AccountLocalStore _accountLocal;
  final _effects = StreamController<ProfileEffect>.broadcast();

  Stream<ProfileEffect> get effects => _effects.stream;

  void hydrateFromCache() {
    final user = cachedUser;
    if (user == null) return;
    emit(
      state.copyWith(
        name: user.name,
        avatarUrl: user.avatarUrl,
        title: user.title,
        email: user.email,
      ),
    );
  }

  /// Fetches `GET /auth/profile`, updates display state, and hydrates related
  /// cubits. Returns whether the network call succeeded.
  Future<bool> loadProfile({bool showLoading = true}) async {
    if (state.isLoadingProfile) return false;
    if (showLoading) emit(state.copyWith(isLoadingProfile: true));

    try {
      final result = await GetProfileUseCase(_authRepo).invoke();
      final profile = result.getOrElse((error) {
        _effects.add(ProfileErrorEffect(error.toString()));
        return null;
      });

      if (profile == null) {
        hydrateFromCache();
        return false;
      }

      _applyProfile(profile);
      return true;
    } finally {
      if (!isClosed) emit(state.copyWith(isLoadingProfile: false));
    }
  }

  Future<bool> refreshProfile() => loadProfile(showLoading: true);

  void _applyProfile(UserProfile profile) {
    final user = profile.user;
    emit(
      state.copyWith(
        name: user.name,
        avatarUrl: user.avatarUrl,
        title: user.title,
        email: user.email,
      ),
    );

    getIt.get<GamificationCubit>().applyFromProfile(profile);
    unawaited(getIt.get<HomeCubit>().loadUserGreeting());
  }

  Future<void> clearUserSession(BuildContext context) async {
    if (state.isLoggingOut) return;
    emit(state.copyWith(isLoggingOut: true));

    try {
      // Capture uid before Firebase sign-out clears currentUser.
      final uid =
          cachedUser?.id ?? FirebaseAuth.instance.currentUser?.uid;

      // Persist local progress + drop the mini-player before auth dies.
      await getIt.get<StoryPlaybackCubit>().clearForLogout();

      // Sign out first so a failure does not leave Firebase signed-in
      // after local session wipe.
      final signOutResult = await _authRepo.signOut();
      if (!signOutResult.isSuccess) {
        _effects.add(
          ProfileErrorEffect(
            signOutResult.error?.toString() ?? 'Sign out failed.',
          ),
        );
        return;
      }

      await _accountLocal.clearActiveSession(uid: uid);
      await getIt.get<ReadingPreferencesCubit>().reload();

      // Process-wide singletons — wipe so the next account cannot inherit
      // XP, read time, continue-reading, or the prior tab selection.
      getIt.get<GamificationCubit>().resetForLogout();
      getIt.get<HomeCubit>().clearSessionData();
      emit(const AccountState());

      logg('Session cleared (account snapshots kept for uid=$uid)');
      _effects.add(const ProfileLoggedOutEffect());
      if (context.mounted) {
        context.pushNamedAndClear(LoginScreen.id);
      }
    } catch (e) {
      _effects.add(ProfileErrorEffect(e.toString()));
    } finally {
      if (!isClosed) emit(state.copyWith(isLoggingOut: false));
    }
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}
