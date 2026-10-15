import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/validation.dart';
import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:stela_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:stela_mobile/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

sealed class AuthEffect {
  const AuthEffect();
}

final class AuthFailureEffect extends AuthEffect {
  const AuthFailureEffect(this.message);
  final String message;
}

final class AuthSuccessEffect extends AuthEffect {
  const AuthSuccessEffect(this.credential, {this.requiresSetup = false});
  final UserCredential credential;

  /// True when this auth result should continue through profile setup.
  final bool requiresSetup;
}

final class AuthPasswordResetEffect extends AuthEffect {
  const AuthPasswordResetEffect();
}

enum AuthFormMode { login, register, forgot }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.mode = AuthFormMode.login,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.age = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isValidated = false,
    this.loading = false,
    this.googleLoading = false,
    this.appleLoading = false,
  });

  final AuthFormMode mode;
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String age;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isValidated;
  final bool loading;
  final bool googleLoading;
  final bool appleLoading;

  LoginPayload get loginPayload =>
      LoginPayload(email: email, password: password);

  UserPayload get payload => UserPayload(email: email, password: password);

  AuthFormState copyWith({
    AuthFormMode? mode,
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? age,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool? isValidated,
    bool? loading,
    bool? googleLoading,
    bool? appleLoading,
  }) {
    return AuthFormState(
      mode: mode ?? this.mode,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      age: age ?? this.age,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      isValidated: isValidated ?? this.isValidated,
      loading: loading ?? this.loading,
      googleLoading: googleLoading ?? this.googleLoading,
      appleLoading: appleLoading ?? this.appleLoading,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    email,
    password,
    confirmPassword,
    name,
    age,
    emailError,
    passwordError,
    confirmPasswordError,
    isValidated,
    loading,
    googleLoading,
    appleLoading,
  ];
}

class AuthCubit extends Cubit<AuthFormState> {
  AuthCubit({
    AuthRepository? repository,
    AuthFormMode mode = AuthFormMode.login,
  }) : _repo = repository ?? getIt.get<AuthRepository>(),
       super(AuthFormState(mode: mode));

  final AuthRepository _repo;
  final _effects = StreamController<AuthEffect>.broadcast();

  Stream<AuthEffect> get effects => _effects.stream;

  void setMode(AuthFormMode mode) {
    emit(
      state.copyWith(
        mode: mode,
        isValidated: _computeValidated(
          mode: mode,
          email: state.email,
          password: state.password,
          confirmPassword: state.confirmPassword,
        ),
      ),
    );
  }

  void setEmail(String email) {
    final emailError = email.validateEmail();
    emit(
      state.copyWith(
        email: email,
        emailError: emailError,
        clearEmailError: emailError == null,
        isValidated: _computeValidated(
          mode: state.mode,
          email: email,
          password: state.password,
          confirmPassword: state.confirmPassword,
        ),
      ),
    );
  }

  void setPassword(String password) {
    final passwordError = password.validatePassword();
    emit(
      state.copyWith(
        password: password,
        passwordError: passwordError,
        clearPasswordError: passwordError == null,
        confirmPasswordError: state.mode == AuthFormMode.register
            ? state.confirmPassword.validateRePassword(password)
            : null,
        clearConfirmPasswordError:
            state.mode != AuthFormMode.register ||
            state.confirmPassword.validateRePassword(password) == null,
        isValidated: _computeValidated(
          mode: state.mode,
          email: state.email,
          password: password,
          confirmPassword: state.confirmPassword,
        ),
      ),
    );
  }

  void setConfirmPassword(String password) {
    final confirmError = password.validateRePassword(state.password);
    emit(
      state.copyWith(
        confirmPassword: password,
        confirmPasswordError: confirmError,
        clearConfirmPasswordError: confirmError == null,
        isValidated: _computeValidated(
          mode: state.mode,
          email: state.email,
          password: state.password,
          confirmPassword: password,
        ),
      ),
    );
  }

  void setAge(String age) => emit(state.copyWith(age: age));

  void setName(String name) => emit(state.copyWith(name: name));

  bool _computeValidated({
    required AuthFormMode mode,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    switch (mode) {
      case AuthFormMode.forgot:
        return email.validateEmail() == null;
      case AuthFormMode.login:
        return [
          email.validateEmail() == null,
          password.validatePassword() == null,
        ].validate();
      case AuthFormMode.register:
        return [
          email.validateEmail() == null,
          password.validatePassword() == null,
          confirmPassword.validateRePassword(password) == null,
        ].validate();
    }
  }

  Future<void> createAccount() async {
    if (state.loading) return;
    if (!_computeValidated(
      mode: AuthFormMode.register,
      email: state.email,
      password: state.password,
      confirmPassword: state.confirmPassword,
    )) {
      return;
    }
    emit(state.copyWith(loading: true));

    final result = await CreateAccountUseCase(_repo, state.payload).invoke();
    final value = result.getOrElse((error) {
      _effects.add(AuthFailureEffect(error.toString()));
      return null;
    });

    if (isClosed) return;

    if (value != null) {
      // Brand-new email accounts always need setup, regardless of any
      // leftover device onboarding flag from a previous session.
      await getIt.get<ReadingPreferencesCubit>().reload();
      _effects.add(AuthSuccessEffect(value, requiresSetup: true));
    }
    if (!isClosed) emit(state.copyWith(loading: false));
  }

  Future<void> signInWithGoogle() async {
    if (state.googleLoading || state.appleLoading) return;
    emit(state.copyWith(googleLoading: true));

    final result = await SignInWithGoogleUseCase(_repo).invoke();
    if (isClosed) return;

    if (result.error is CancelledFailure) {
      emit(state.copyWith(googleLoading: false));
      return;
    }

    final value = result.getOrElse((error) {
      _effects.add(AuthFailureEffect(error.toString()));
      return null;
    });

    if (isClosed) return;

    if (value != null) {
      await getIt.get<ReadingPreferencesCubit>().reload();
      _effects.add(
        AuthSuccessEffect(value, requiresSetup: await _requiresSetup()),
      );
    }
    if (!isClosed) emit(state.copyWith(googleLoading: false));
  }

  Future<void> signInWithApple() async {
    if (state.googleLoading || state.appleLoading) return;
    emit(state.copyWith(appleLoading: true));

    final result = await SignInWithAppleUseCase(_repo).invoke();
    if (isClosed) return;

    if (result.error is CancelledFailure) {
      emit(state.copyWith(appleLoading: false));
      return;
    }

    final value = result.getOrElse((error) {
      _effects.add(AuthFailureEffect(error.toString()));
      return null;
    });

    if (isClosed) return;

    if (value != null) {
      await getIt.get<ReadingPreferencesCubit>().reload();
      _effects.add(
        AuthSuccessEffect(value, requiresSetup: await _requiresSetup()),
      );
    }
    if (!isClosed) emit(state.copyWith(appleLoading: false));
  }

  Future<void> signIn() async {
    if (state.loading) return;
    if (!_computeValidated(
      mode: AuthFormMode.login,
      email: state.email,
      password: state.password,
      confirmPassword: state.confirmPassword,
    )) {
      return;
    }
    emit(state.copyWith(loading: true));

    final result = await SignInUseCase(_repo, state.loginPayload).invoke();
    final value = result.getOrElse((error) {
      _effects.add(AuthFailureEffect(error.toString()));
      return null;
    });

    if (isClosed) return;

    if (value != null) {
      await getIt.get<ReadingPreferencesCubit>().reload();
      _effects.add(
        AuthSuccessEffect(value, requiresSetup: await _requiresSetup()),
      );
    }
    if (!isClosed) emit(state.copyWith(loading: false));
  }

  /// After login/Google sync, true when this Firebase user has no profile yet.
  Future<bool> _requiresSetup() async {
    final prefs = await getIt.getAsync<SharedPreferences>();
    return !(prefs.getBool(isOnboardedKey) ?? false);
  }

  Future<void> resetPassword() async {
    if (state.loading) return;
    if (state.email.validateEmail() != null) return;
    emit(state.copyWith(loading: true));

    final result = await ResetPasswordUseCase(_repo, state.email).invoke();
    final value = result.getOrElse((error) {
      _effects.add(AuthFailureEffect(error.toString()));
      return null;
    });

    if (isClosed) return;

    if (value != null) {
      _effects.add(const AuthPasswordResetEffect());
    }
    if (!isClosed) emit(state.copyWith(loading: false));
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}
