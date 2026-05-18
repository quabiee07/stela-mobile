import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/utils/validation.dart';
import 'package:stela_mobile/features/auth/domain/models/story_type.dart';
import 'package:stela_mobile/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_state.dart';

class AuthProvider extends CustomProvider {
  final state = AuthState();
  final _repo = getIt.get<AuthRepository>();

  void setEmail(String email) {
    state.email = email;
    state.emailError = email.validateEmail();
    _validate();
  }

  void setPassword(String password) {
    state.password = password;
    state.passwordError = password.validatePassword();
    _validate();
  }

  void setConfirmPassword(String password) {
    state.confirmPassword = password;
    state.confirmPasswordError = password.validateRePassword(state.password);
    _validate();
  }

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

  void _validate() {
    state.isValidated = [
      state.email.validateField() == null,
      state.password.validateField() == null,
      state.confirmPassword.validateRePassword(state.password) == null,
    ].validate();
    notifyListeners();
  }

  void createAccount() async {
    onLoad();

    final result = CreateAccountUseCase(_repo, state.payload).invoke();
    result.then((value) {
      final result = value.getOrElse((error) {
        add(error);
        return null;
      });

      if (result != null) {
        add(result);
      }
      onLoad();
    });
  }

  void signInWithGoogle() async {
    state.googleLoading = true;
    notifyListeners();

    final result = SignInWithGoogleUseCase(_repo).invoke();

    result.then((value) {
      final result = value.getOrElse((error) {
        add(error);
        return null;
      });

      if (result != null) {
        add(result);
      }
      state.googleLoading = false;
      notifyListeners();
    });
  }

  void signIn() async {
    onLoad();

    final result = SignInUseCase(_repo, state.loginPayload).invoke();

    result.then((value) {
      final result = value.getOrElse((error) {
        add(error);
        return null;
      });

      if (result != null) {
        add(result);
      }
      onLoad();
    });
  }
}
