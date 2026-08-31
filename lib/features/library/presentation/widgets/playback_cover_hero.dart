import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/library/presentation/utils/playback_hero_tags.dart';

class PlaybackCoverHero extends StatelessWidget {
  const PlaybackCoverHero({
    required this.storyId,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String storyId;
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final hasNetwork = imageUrl.isNotEmpty && imageUrl.startsWith('http');
    final resolvedUrl = imageUrl.isNotEmpty ? imageUrl : boyDragon;

    final image = hasNetwork
        ? CachedImage(asset: imageUrl, fit: fit)
        : CustomImage(asset: resolvedUrl, fit: fit);

    final sized = width != null || height != null
        ? SizedBox(width: width, height: height, child: image)
        : SizedBox.expand(child: image);

    return Hero(
      tag: PlaybackHeroTags.cover(storyId),
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: sized,
        ),
      ),
    );
  }
}
