import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/image_shimmer.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.height,
    this.color,
    this.width,
  });
  final String asset;
  final BoxFit fit;

  final double? height;

  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return FastCachedImage(
      key: ValueKey(asset),
      url: asset,
      fit: fit,
      height: height,
      width: width,
      fadeInDuration: const Duration(milliseconds: 120),
      loadingBuilder: (context, progress) {
        return SizedBox(
          height: height,
          width: width,
          child: ImageShimmer(width: width, height: height),
        );
      },
      errorBuilder: (context, exception, stacktrace) {
        return SizedBox(
          height: height,
          width: width,
          child: ColoredBox(
            color: context.chipFill,
            child: Icon(
              Icons.broken_image_outlined,
              color: context.mutedText,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
