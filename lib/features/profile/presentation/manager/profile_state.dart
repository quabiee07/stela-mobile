import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';
import 'package:stela_mobile/features/profile/domain/models/user_profile.dart';

class ProfileState {
  UserProfile? user;
  bool newBadgeUnlocked = false;
  String? streakMessage;
  bool isReminderEnabled = false;
  int reminderHour = 8;
  StreakInfo? streakInfo;
  List<UserBadge> badges = [];
  bool streakFreezeActivated = false;

  DailyReminderPayload get payload => DailyReminderPayload(
    dailyReminderEnabled: isReminderEnabled,
    reminderHour: reminderHour,
  );
}
