import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';

/// Thin wrapper so call sites stay consistent app-wide.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.5,
  });

  final AppIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: icon,
      size: size,
      color: color ?? IconTheme.of(context).color ?? Colors.black,
      strokeWidth: strokeWidth,
    );
  }
}
