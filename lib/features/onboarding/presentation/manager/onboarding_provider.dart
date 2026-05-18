import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/features/onboarding/presentation/manager/onboarding_state.dart';

class OnboardingProvider extends CustomProvider {
  final _pref = getIt.getAsync<SharedPreferences>();
  var state = OnboardingState();

  bool get isEnd => state.currentIndex == state.onboardingPages.length - 1;

  void init() {
    state = OnboardingState();
    notifyListeners();
  }

  void setIndex(int value) {
    state.currentIndex = value;
    notifyListeners();
  }

  void setOnboarding() {
    _pref.then((value) {
      value.setBool(onboardingKey, true);
    });
  }
}
