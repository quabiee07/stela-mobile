import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class LibraryStory extends StatelessWidget {
  const LibraryStory({
    super.key,
    required this.story,
    required this.onStoryTap,
    this.height,
    this.width,
  });

  final StorySummary story;
  final Function(StorySummary) onStoryTap;
  final double? height;
  final double? width;

  /// Title + tags + stars + gaps below the cover.
  static const double metaHeight = 68;

  @override
  Widget build(BuildContext context) {
    final cover = story.coverImageUrl;
    final hasNetworkCover = cover.startsWith('http');
    final hasAssetCover = cover.isNotEmpty && !hasNetworkCover;
    final coverWidth = width ?? 140.0;
    final coverHeight = height ?? 150.0;

    return GestureDetector(
      onTap: () => onStoryTap(story),
      child: SizedBox(
        width: coverWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasNetworkCover
                  ? CachedImage(
                      key: ValueKey(cover),
                      asset: cover,
                      width: coverWidth,
                      height: coverHeight,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(
                      key: ValueKey(
                        hasAssetCover ? cover : 'fallback_${story.storyId}',
                      ),
                      asset: hasAssetCover ? cover : boyDragon,
                      width: coverWidth,
                      height: coverHeight,
                      fit: BoxFit.cover,
                    ),
            ),
            const Gap(8),
            Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              story.tags,
              style: TextStyle(color: context.mutedText, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(4),
            Row(
              children: List.generate(5, (index) {
                return const AppIcon(AppIcons.star, color: amber, size: 14);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
