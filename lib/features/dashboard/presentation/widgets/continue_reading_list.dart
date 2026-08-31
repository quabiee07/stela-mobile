import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';

class ContinueReadingList extends StatelessWidget {
  final List<ReadingProgress> items;
  final ValueChanged<ReadingProgress> onStoryTap;
  final int? maxItems;

  const ContinueReadingList({
    super.key,
    required this.items,
    required this.onStoryTap,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = context.cardSurface;
    final muted = context.mutedText;
    final visibleItems =
        maxItems == null ? items : items.take(maxItems!).toList();

    if (visibleItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Start a story and it will show up here.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
      );
    }

    // Small fixed list — Column avoids nested scroll + shrinkWrap cost.
    return Column(
      children: [
        for (var index = 0; index < visibleItems.length; index++)
          _ContinueReadingCard(
            item: visibleItems[index],
            cardColor: cardColor,
            muted: muted,
            isLast: index == visibleItems.length - 1,
            onStoryTap: onStoryTap,
          ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.item,
    required this.cardColor,
    required this.muted,
    required this.isLast,
    required this.onStoryTap,
  });

  final ReadingProgress item;
  final Color cardColor;
  final Color muted;
  final bool isLast;
  final ValueChanged<ReadingProgress> onStoryTap;

  @override
  Widget build(BuildContext context) {
    final cover = item.coverImageUrl;
    final hasNetworkCover = cover.startsWith('http');

    return GestureDetector(
      onTap: () => onStoryTap(item),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.isDarkTheme
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasNetworkCover
                  ? CachedImage(
                      asset: cover,
                      width: 57,
                      height: 73,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(
                      asset: cover.isNotEmpty ? cover : boyDragon,
                      width: 57,
                      height: 73,
                      fit: BoxFit.cover,
                    ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    item.chapterTitle.isNotEmpty
                        ? 'Chapter ${item.chapterNumber} · ${item.chapterTitle}'
                        : 'Chapter ${item.chapterNumber}',
                    style: TextStyle(color: muted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: item.progress.clamp(0.0, 1.0),
                      backgroundColor: context.softBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(orange),
                      minHeight: 6,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${item.progressPercent}% complete · ${item.timeLabel}',
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Gap(12),
            Container(
              width: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: buttonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'Read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
