import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';

/// Resolves profile photo sources: asset paths, network URLs, or local files.
ImageProvider profileAvatarProvider(
  String avatarUrl, {
  String? localPath,
  String fallbackAsset = femaleAvatar,
}) {
  final local = localPath?.trim();
  if (local != null && local.isNotEmpty) {
    return FileImage(File(local));
  }

  final url = avatarUrl.trim();
  if (url.isEmpty) return AssetImage(fallbackAsset);

  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }

  if (url.startsWith('file://')) {
    return FileImage(File(Uri.parse(url).toFilePath()));
  }

  if (url.startsWith('/') || url.contains('/cache/') || url.contains('/tmp/')) {
    final file = File(url);
    if (file.existsSync()) return FileImage(file);
  }

  return AssetImage(url.startsWith('assets/') ? url : fallbackAsset);
}

/// Circle avatar that supports asset, network, and local file photos.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    this.localPath,
    this.radius = 40,
    this.backgroundColor = const Color(0xFFF3ABA7),
    this.progress,
    this.progressColor = orange,
  });

  final String avatarUrl;
  final String? localPath;
  final double radius;
  final Color backgroundColor;

  /// 0–1 XP progress around the avatar. Null hides the ring.
  final double? progress;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final avatar = _AvatarImage(
      avatarUrl: avatarUrl,
      localPath: localPath,
      radius: radius,
      backgroundColor: backgroundColor,
    );

    final fraction = progress;
    if (fraction == null) return avatar;

    const stroke = 6.0;
    const gap = 5.0;
    final ringSize = radius * 2 + (stroke + gap) * 2;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: ringSize,
          height: ringSize,
          child: CustomPaint(
            painter: _XpRingPainter(
              progress: value,
              color: progressColor,
              trackColor: progressColor.withValues(alpha: 0.2),
              strokeWidth: stroke,
            ),
            child: Padding(
              padding: const EdgeInsets.all(stroke + gap),
              child: avatar,
            ),
          ),
        );
      },
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.avatarUrl,
    required this.localPath,
    required this.radius,
    required this.backgroundColor,
  });

  final String avatarUrl;
  final String? localPath;
  final double radius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl.trim();
    final local = localPath?.trim();
    final size = radius * 2;

    if ((local == null || local.isEmpty) &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CachedImage(
            asset: url,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: profileAvatarProvider(avatarUrl, localPath: localPath),
    );
  }
}

class _XpRingPainter extends CustomPainter {
  const _XpRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _XpRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
