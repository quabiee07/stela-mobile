import 'package:flutter/material.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';

class BadgeImage extends StatelessWidget {
  const BadgeImage({
    super.key,
    required this.definition,
    this.size = 72,
    this.unlocked = true,
  });

  final BadgeDefinition definition;
  final double size;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (definition.asset.isNotEmpty) {
      image = Image.asset(
        definition.asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      image = SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(definition.icon, style: TextStyle(fontSize: size * 0.45)),
        ),
      );
    }

    if (unlocked) return image;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Opacity(opacity: 0.72, child: image),
    );
  }
}
