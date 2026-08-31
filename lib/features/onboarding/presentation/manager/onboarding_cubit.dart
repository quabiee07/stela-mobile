import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/models/onboarding_model.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';

class OnboardingState extends Equatable {
  OnboardingState({
    this.currentIndex = 0,
    List<OnboardingModel>? pages,
  }) : pages = pages ?? _defaultPages;

  static final List<OnboardingModel> _defaultPages = [
    OnboardingModel(
      image: mascot1,
      title: 'Where\nStories Come Alive',
      description: '',
    ),
    OnboardingModel(
      image: mascot2,
      title: 'Stories\nfor Every Dream',
      description: '',
    ),
    OnboardingModel(
      image: mascot3,
      title: 'Illustrations\nMade By Magic',
      description: '',
    ),
  ];

  final int currentIndex;
  final List<OnboardingModel> pages;

  bool get isEnd => currentIndex >= pages.length - 1;

  OnboardingState copyWith({int? currentIndex}) => OnboardingState(
        currentIndex: currentIndex ?? this.currentIndex,
        pages: pages,
      );

  @override
  List<Object?> get props => [currentIndex, pages];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._prefsFuture) : super(OnboardingState());

  final Future<SharedPreferences> _prefsFuture;

  void setIndex(int value) => emit(state.copyWith(currentIndex: value));

  Future<void> markOnboardingSeen() async {
    final prefs = await _prefsFuture;
    await prefs.setBool(onboardingKey, true);
  }
}

OnboardingCubit createOnboardingCubit() =>
    OnboardingCubit(getIt.getAsync<SharedPreferences>());
