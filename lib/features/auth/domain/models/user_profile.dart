import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';

/// Profile returned by `GET /auth/profile`, mapped onto the app's [UserModel]
/// plus fields the UI needs that aren't stored on [UserModel] yet.
class UserProfile {
  const UserProfile({
    required this.user,
    required this.streak,
    required this.longestStreak,
    required this.streakStatus,
    this.timezone,
    this.notificationPreferences,
  });

  final UserModel user;
  final StreakInfo streak;
  final int longestStreak;
  final String streakStatus;
  final String? timezone;
  final DailyReminderPayload? notificationPreferences;
}
