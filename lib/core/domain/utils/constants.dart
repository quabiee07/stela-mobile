

import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

String accessToken = '';
String userType = '';
// UserRole? currentRole;
bool isFirstTime = false;

UserModel? cachedUser;

double latitude = 0.0;
double longitude = 0.0;

// Shared preference keys
String onboardingKey = 'onboarding';
String tokenKey = 'token';
String userRoleKey = 'user-role';
String isFirstTimeKey = 'isFirstTime';
String userKey = 'user';
String savedIds = 'savedIds';
String currentEmail = 'currentEmail';
String naira = '₦';

