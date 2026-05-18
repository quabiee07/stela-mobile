import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

class BadgeUnlockOverlay extends StatelessWidget {
  final String iconAsset;
  final String badgeName;
  final VoidCallback onDismiss;

  const BadgeUnlockOverlay({
    Key? key,
    required this.iconAsset,
    required this.badgeName,
    required this.onDismiss,
  }) : super(key: key);

  static void show(BuildContext context, String iconAsset, String badgeName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return BadgeUnlockOverlay(
          iconAsset: iconAsset,
          badgeName: badgeName,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: grey100,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Badge Unlocked!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ).animate().fade().slideY(begin: 0.5, curve: Curves.easeOutQuad),
                const SizedBox(height: 24),
                Text(
                  iconAsset,
                  style: const TextStyle(fontSize: 80),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms)
                    .animate()
                    .fade(duration: 500.ms)
                    .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  badgeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.5, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
