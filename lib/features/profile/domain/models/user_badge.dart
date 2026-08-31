import 'package:stela_mobile/features/profile/domain/models/api_timestamp.dart';

class UserBadge {
  final String badgeId;
  final ApiTimestamp? unlockedAt;
  final bool seen;

  const UserBadge({
    required this.badgeId,
    required this.unlockedAt,
    required this.seen,
  });
}
