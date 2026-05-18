import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/features/auth/domain/models/story_type.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_state.dart';

class SetupProvider extends CustomProvider {
  final state = AuthState();

  void toggleStoryType(StoryType storyType) {
    if (state.selectedStoryTypes.contains(storyType)) {
      state.selectedStoryTypes.remove(storyType);
      state.favouriteGenres.remove(storyType.name);
    } else {
      state.selectedStoryTypes.add(storyType);
      state.favouriteGenres.add(storyType.name);
    }
    notifyListeners();
  }

  void setAge(String age) {
    state.age = age;
    notifyListeners();
  }

  void setName(String name) {
    state.name = name;
    notifyListeners();
  }
}
