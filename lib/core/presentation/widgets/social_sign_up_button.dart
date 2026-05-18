import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';

class SocialSignUpButton extends StatelessWidget {
  const SocialSignUpButton({
    super.key,
    required this.isGoogle,
    this.text,
    this.onTap,
    required this.isLoading,
    this.color,
  });

  final bool isGoogle;
  final bool isLoading;
  final String? text;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: isLoading == true
            ? Center(
                child: LoadingAnimationWidget.waveDots(
                  color: Colors.black,
                  size: 28,
                ),
              )
            : Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(
                    asset: isGoogle ? google : apple,
                    height: 22,
                    width: 22,
                  ),
                  Text(
                    text ?? (isGoogle ? 'Google' : 'Apple'),
                    style: theme.textTheme.displaySmall?.copyWith(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
