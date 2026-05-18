import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<dynamic> avatarUrls;
  final int maxDisplayed;
  final double avatarSize;
  final double overlap;

  const OverlappingAvatars({
    super.key,
    required this.avatarUrls,
    this.maxDisplayed = 3,
    this.avatarSize = 40,
    this.overlap = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int displayCount =
        avatarUrls.length > maxDisplayed ? maxDisplayed : avatarUrls.length;
    double containerWidth =
        avatarSize + (avatarSize * (1 - overlap) * (displayCount - 1));

    return SizedBox(
      width: containerWidth + (avatarUrls.length > maxDisplayed ? 40 : 0),
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
                left: i * avatarSize * (1 - overlap),
                child: Container(
                  height: avatarSize,
                  width: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 1.3, color: theme.colorScheme.surface),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedImage(
                      asset: avatarUrls[i].path,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
