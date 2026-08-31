import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/data/storage/account_local_store.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/auth/domain/models/profile_setup_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/story_type.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/domain/usecases/setup_profile_usecase.dart';

class SetupState extends Equatable {
  const SetupState({
    this.name = '',
    this.age = '',
    this.selectedStoryTypes = const {},
    this.favouriteGenres = const [],
    this.isSubmitting = false,
  });

  final String name;
  final String age;
  final Set<StoryType> selectedStoryTypes;
  final List<String> favouriteGenres;
  final bool isSubmitting;

  ProfileSetupPayload get profileSetupPayload => ProfileSetupPayload(
        name: name,
        age: int.tryParse(age) ?? 0,
        storyPreferences: favouriteGenres,
      );

  SetupState copyWith({
    String? name,
    String? age,
    Set<StoryType>? selectedStoryTypes,
    List<String>? favouriteGenres,
    bool? isSubmitting,
  }) {
    return SetupState(
      name: name ?? this.name,
      age: age ?? this.age,
      selectedStoryTypes: selectedStoryTypes ?? this.selectedStoryTypes,
      favouriteGenres: favouriteGenres ?? this.favouriteGenres,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        name,
        age,
        selectedStoryTypes,
        favouriteGenres,
        isSubmitting,
      ];
}

sealed class SetupEffect {
  const SetupEffect();
}

final class SetupErrorEffect extends SetupEffect {
  const SetupErrorEffect(this.message);
  final String message;
}

final class SetupCompleteEffect extends SetupEffect {
  const SetupCompleteEffect(this.result);
  final GenericModel result;
}

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(this._repo) : super(const SetupState());

  final AuthRepository _repo;
  final _effects = StreamController<SetupEffect>.broadcast();

  Stream<SetupEffect> get effects => _effects.stream;

  void toggleStoryType(StoryType storyType) {
    final types = Set<StoryType>.from(state.selectedStoryTypes);
    final genres = List<String>.from(state.favouriteGenres);

    if (types.contains(storyType)) {
      types.remove(storyType);
      genres.remove(storyType.name);
    } else {
      types.add(storyType);
      genres.add(storyType.name);
    }

    emit(
      state.copyWith(
        selectedStoryTypes: types,
        favouriteGenres: genres,
      ),
    );
  }

  void setAge(String age) => emit(state.copyWith(age: age));

  void setName(String name) => emit(state.copyWith(name: name));

  Future<void> completeOnboarding() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));

    final result = await SetupProfileUseCase(
      _repo,
      state.profileSetupPayload,
    ).invoke();

    final value = result.getOrElse((error) {
      _effects.add(SetupErrorEffect(error.toString()));
      return null;
    });

    if (value != null) {
      await _repo.saveUserProfile(state.profileSetupPayload);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(isOnboardedKey, true);
      final uid =
          cachedUser?.id ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await AccountLocalStore().markOnboarded(uid, onboarded: true);
      }
      _effects.add(SetupCompleteEffect(value));
    }

    emit(state.copyWith(isSubmitting: false));
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

SetupCubit createSetupCubit() => SetupCubit(getIt.get<AuthRepository>());
