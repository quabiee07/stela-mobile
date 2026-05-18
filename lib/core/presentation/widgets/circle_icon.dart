import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class CircleIcon extends StatelessWidget {
  final String asset;
  const CircleIcon({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final theme =  Theme.of(context);
    return Container(
      height: 46,
      width: 46, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        shape: BoxShape.circle,
      ),
      child: SvgImage(asset: asset),
    );
  }
}
