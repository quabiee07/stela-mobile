import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

String userType = '';
bool isFirstTime = false;

UserModel? cachedUser;

double latitude = 0.0;
double longitude = 0.0;

// Shared preference keys (non-secrets only — tokens use SecureTokenStorage)
String onboardingKey = 'onboarding';
@Deprecated('Tokens must use SecureTokenStorage, not SharedPreferences')
String tokenKey = 'token';
String userRoleKey = 'user-role';
String isFirstTimeKey = 'isFirstTime';
String userKey = 'user';
String savedIds = 'savedIds';
String isOnboardedKey = 'isOnboarded';
String currentEmail = 'currentEmail';
String isReminderEnabledKey = 'isReminderEnabled';
String reminderHourKey = 'reminderHour';
String naira = '₦';

const stelaBaseUrl = "https://stela-mobile.web.app/api/";
String? fcmToken;
String region = "";
