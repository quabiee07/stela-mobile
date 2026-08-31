import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/data/storage/account_local_store.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

class AccountState extends Equatable {
  const AccountState({this.isLoggingOut = false});

  final bool isLoggingOut;

  AccountState copyWith({bool? isLoggingOut}) =>
      AccountState(isLoggingOut: isLoggingOut ?? this.isLoggingOut);

  @override
  List<Object?> get props => [isLoggingOut];
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

class ProfileCubit extends Cubit<AccountState> {
  ProfileCubit(this._authRepo, this._accountLocal) : super(const AccountState());

  final AuthRepository _authRepo;
  final AccountLocalStore _accountLocal;
  final _effects = StreamController<ProfileEffect>.broadcast();

  Stream<ProfileEffect> get effects => _effects.stream;

  Future<void> clearUserSession(BuildContext context) async {
    if (state.isLoggingOut) return;
    emit(state.copyWith(isLoggingOut: true));

    try {
      // Capture uid before Firebase sign-out clears currentUser.
      final uid =
          cachedUser?.id ?? FirebaseAuth.instance.currentUser?.uid;

      await _accountLocal.clearActiveSession(uid: uid);
      await _authRepo.signOut();
      await getIt.get<ReadingPreferencesCubit>().reload();

      logg('Session cleared (account snapshots kept for uid=$uid)');
      _effects.add(const ProfileLoggedOutEffect());
      if (context.mounted) {
        context.pushNamedAndClear(LoginScreen.id);
      }
    } catch (e) {
      _effects.add(ProfileErrorEffect(e.toString()));
    } finally {
      emit(state.copyWith(isLoggingOut: false));
    }
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

ProfileCubit createProfileCubit() => ProfileCubit(
      getIt.get<AuthRepository>(),
      AccountLocalStore(),
    );
