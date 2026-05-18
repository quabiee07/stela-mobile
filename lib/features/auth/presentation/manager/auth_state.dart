import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/story_type.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';

class AuthState {
  bool googleLoading = false;
  bool isValidated = false;
  String email = '';
  String? emailError;

  String password = '';
  String? passwordError;

  String confirmPassword = '';
  String? confirmPasswordError;

  String name = '';
  String? nameError;

  String age = '';

  Set<StoryType> selectedStoryTypes = {};
  List<String> favouriteGenres = [];

  UserPayload get payload => UserPayload(
    email: email,
    password: password,
    name: name,
    age: age,
    favoriteGenres: favouriteGenres,
  );

  LoginPayload get loginPayload => LoginPayload(
    email: email,
    password: password,
  );
}
