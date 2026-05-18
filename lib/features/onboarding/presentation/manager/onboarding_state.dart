import 'package:stela_mobile/core/domain/models/onboarding_model.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';

class OnboardingState {
  int currentIndex = 0;
  List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      image: onboard1,
      title: 'Where\nStories Come Alive',
      description: '',
    ),
    OnboardingModel(
      image: onboard2,
      title: 'Stories\nfor Every Dream',
      description: '',
    ),
    OnboardingModel(
      image: onboard3,
      title: 'Illustrations\nMade By Magic',
      description: '',
    ),
  ];
}
