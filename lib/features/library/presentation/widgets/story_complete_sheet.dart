import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

Future<void> showStoryCompleteSheet(
  BuildContext context, {
  required String storyTitle,
  required int chaptersCompleted,
  int? currentStreak,
  int? xpEarned,
  List<String> newBadges = const [],
  required Future<bool> Function() onShareXp,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      var sharing = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: grey200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(24),
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon(
                      AppIcons.bookOpen,
                      color: orange,
                      size: 36,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    'Story complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'You finished "$storyTitle".',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: grey500,
                      height: 1.4,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    '$chaptersCompleted chapters listened',
                    style: const TextStyle(
                      fontSize: 13,
                      color: grey500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (xpEarned != null && xpEarned > 0) ...[
                    const Gap(12),
                    Text(
                      '+$xpEarned XP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: orange,
                      ),
                    ),
                  ],
                  if (currentStreak != null && currentStreak > 0) ...[
                    const Gap(20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 28)),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              '$currentStreak-day reading streak',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (newBadges.isNotEmpty) ...[
                    const Gap(16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: newBadges.map((badgeId) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: grey100,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                GamificationDisplay.badgeIcon(badgeId),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Gap(6),
                              Text(
                                GamificationDisplay.badgeName(badgeId),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const Gap(28),
                  Clickable(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      final navigator = Navigator.of(sheetContext);
                      if (navigator.canPop()) navigator.pop();
                      if (navigator.canPop()) navigator.pop();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Back to library',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Clickable(
                    isEnabled: !sharing,
                    onPressed: () {
                      setState(() => sharing = true);
                      onShareXp().then((success) {
                        if (!sheetContext.mounted) return;
                        if (success) {
                          sheetContext.showSuccess(
                            'Shared! +25 XP added to your profile.',
                          );
                        } else {
                          sheetContext.showError(
                            'Could not share right now. Try again later.',
                          );
                        }
                      }).whenComplete(() {
                        if (context.mounted) {
                          setState(() => sharing = false);
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: grey100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: sharing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Share & earn +25 XP',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Clickable(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text(
                      'Stay on this page',
                      style: TextStyle(
                        color: grey500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
