import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/badge_image.dart';

/// Profile badge preview — shows up to [collapsedCount] badges; All Badges opens
/// a sheet with the full locked + unlocked catalog.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({
    super.key,
    required this.badges,
    this.title = 'My Badges',
    this.collapsedCount = 4,
  });

  final List<BadgeProgress> badges;
  final String title;

  /// Max badges shown on the profile (prefer unlocked first).
  final int collapsedCount;

  List<BadgeProgress> get _preview {
    final unlocked = badges.where((b) => b.unlocked).toList();
    if (unlocked.length >= collapsedCount) {
      return unlocked.take(collapsedCount).toList();
    }
    final remaining = collapsedCount - unlocked.length;
    final locked = badges.where((b) => !b.unlocked).take(remaining);
    return [...unlocked, ...locked];
  }

  void _openAllBadges(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AllBadgesSheet(badges: badges);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badges.length > collapsedCount)
              Clickable(
                onPressed: () => _openAllBadges(context),
                child: const Text(
                  'All Badges',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: orange,
                  ),
                ),
              ),
          ],
        ),
        const Gap(16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < collapsedCount; i++)
              Expanded(
                child: i < preview.length
                    ? _BadgeTile(badge: preview[i])
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ],
    );
  }
}

class _AllBadgesSheet extends StatelessWidget {
  const _AllBadgesSheet({required this.badges});

  final List<BadgeProgress> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.6;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Gap(10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.softBorder,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const Gap(16),
          Text(
            'All Badges',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                return _BadgeTile(badge: badges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;

    return Column(
      children: [
        BadgeImage(definition: badge.definition, size: 68, unlocked: unlocked),
        const Gap(6),
        // if (requirement.isNotEmpty)
        //   Text(
        //     requirement,
        //     textAlign: TextAlign.center,
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //     style: TextStyle(
        //       fontSize: 10,
        //       color: context.mutedText,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        Text(
          badge.definition.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
