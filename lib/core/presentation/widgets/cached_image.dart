import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    return FastCachedImage(
      url: asset,
      fit: fit,
      height: height,
      width: width,
      loadingBuilder: (context, progress) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.tertiary,
              value: progress.progressPercentage.value,
            ),
          ),
        );
      },
    );
  }
}
