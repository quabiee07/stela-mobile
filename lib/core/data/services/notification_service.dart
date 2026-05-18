// import 'package:stela_mobile/core/domain/utils/utilities.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();

//   factory NotificationService() {
//     return _instance;
//   }

//   NotificationService._internal();

//   Future<void> init() async {
//     // TODO: Initialize FlutterLocalNotificationsPlugin or FirebaseMessaging here
//     logg('NotificationService initialized');
//   }

//   Future<void> scheduleDailyReminder() async {
//     // TODO: Implement "Hey [Name], don't break your streak! Your book is waiting 📖"
//     logg('Scheduled daily reminder');
//   }

//   Future<void> sendStreakAtRiskWarning(int streakDays) async {
//     // TODO: Implement "You haven't read today. Your [X]-day streak is on the line!"
//     logg('Sent streak at risk warning for $streakDays days');
//   }

//   Future<void> sendMilestoneReached(int streakDays) async {
//     // TODO: Implement "You hit a [X]-day streak on Stela! Share it and earn XP 🏆"
//     logg('Sent milestone reached for $streakDays days');
//   }

//   Future<void> cancelAllNotifications() async {
//     // TODO: Clear scheduled notifications
//     logg('Cancelled all notifications');
//   }
// }
