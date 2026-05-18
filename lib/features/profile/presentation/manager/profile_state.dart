import 'package:stela_mobile/features/profile/domain/models/user_profile.dart';

class ProfileState {
  UserProfile? user;
  bool newBadgeUnlocked = false;
  String? streakMessage;
}
