import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';

/// Shared badge grid — collapsed shows unlocked badges only; expand for full catalog.
class BadgeGrid extends StatefulWidget {
  const BadgeGrid({
    super.key,
    required this.badges,
    this.title = 'My Badges',
    this.collapsedCount = 2,
    this.initiallyExpanded = false,
  });

  final List<BadgeProgress> badges;
  final String title;

  /// Max unlocked badges shown while collapsed.
  final int collapsedCount;
  final bool initiallyExpanded;

  @override
  State<BadgeGrid> createState() => _BadgeGridState();
}

class _BadgeGridState extends State<BadgeGrid> {
  late bool _expanded = widget.initiallyExpanded;

  List<BadgeProgress> get _unlocked =>
      widget.badges.where((b) => b.unlocked).toList();

  List<BadgeProgress> get _visible {
    if (_expanded) return widget.badges;
    final unlocked = _unlocked;
    if (unlocked.isEmpty) {
      return widget.badges.take(widget.collapsedCount).toList();
    }
    return unlocked.take(widget.collapsedCount).toList();
  }

  bool get _showToggle => widget.badges.length > _visible.length || _expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_showToggle) ...[
              const Gap(10),
              Clickable(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Show all badges',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: orange,
                      ),
                    ),
                    const Gap(4),
                    Transform.rotate(
                      angle: _expanded ? math.pi : 0,
                      child: const AppIcon(
                        AppIcons.arrowDown,
                        size: 16,
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const Gap(8),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: 12,
            runSpacing: 14,
            children: _visible
                .map((badge) => _BadgeTile(badge: badge))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.45,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: unlocked
                    ? Border.all(color: orange.withValues(alpha: 0.35))
                    : null,
              ),
              child: Center(
                child: Text(
                  badge.definition.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const Gap(6),
          Text(
            badge.definition.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: context.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!unlocked) ...[
            const Gap(4),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: badge.fraction,
                minHeight: 3,
                backgroundColor: context.softBorder,
                valueColor: const AlwaysStoppedAnimation(orange),
              ),
            ),
            const Gap(2),
            Text(
              '${badge.current}/${badge.definition.target}',
              style: TextStyle(fontSize: 9, color: context.mutedText),
            ),
          ],
        ],
      ),
    );
  }
}
