import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';

Future<ChapterSummary?> showChapterSelectorSheet(
  BuildContext context, {
  required List<ChapterSummary> chapters,
  required String currentChapterId,
  String fallbackImageUrl = '',
}) {
  return showModalBottomSheet<ChapterSummary>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final maxHeight = MediaQuery.of(sheetContext).size.height * 0.7;
      final onSurface = Theme.of(sheetContext).colorScheme.onSurface;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: sheetContext.cardSurface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: sheetContext.softBorder,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const Gap(20),
              Text(
                'Chapters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const Gap(4),
              Text(
                '${chapters.length} chapters',
                style: TextStyle(
                  fontSize: 13,
                  color: sheetContext.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: chapters.length,
                  separatorBuilder: (_, _) => const Gap(8),
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    final isSelected = chapter.chapterId == currentChapterId;

                    return Clickable(
                      onPressed: () => Navigator.of(sheetContext).pop(chapter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? orange.withValues(alpha: 0.12)
                              : sheetContext.elevatedSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? orange : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? orange.withValues(alpha: 0.2)
                                    : sheetContext.chipFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? orange : onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chapter ${chapter.chapterNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? orange
                                          : sheetContext.mutedText,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    chapter.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const AppIcon(
                                AppIcons.checkCircle,
                                size: 22,
                                color: orange,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
