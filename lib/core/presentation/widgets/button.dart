import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.title,
    this.isLoading = false,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.height,
    this.color,
  });

  final String title;
  final bool isLoading;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height ?? 48,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (!isEnabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ??
              (isLoading
                  ? disabledGrey
                  : (isEnabled ? Colors.white : disabledGrey)),
        ),
        child: isLoading == true
            ? LoadingAnimationWidget.waveDots(
                color: theme.colorScheme.surface,
                size: 28,
              )
            : Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: (isLoading
                      ? disabledGrey
                      : (isEnabled ? Colors.black : textGrey)),
                ),
              ),
      ),
    );
  }
}

class Button2 extends StatelessWidget {
  const Button2({
    super.key,
    required this.title,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });
  final String title;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onPressed: onPressed,
      child: Container(
        height: 54,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: (isLoading
              ? disabledButtonGradient
              : (isEnabled ? buttonGradient : disabledButtonGradient)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: (isEnabled || isLoading) ? orange : Color(0xFF8C7B77),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: isLoading == true
                ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 28)
                : Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class BorderButton extends StatelessWidget {
  const BorderButton({
    super.key,
    required this.title,
    this.isLoading = false,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.height,
    this.color,
  });

  final String title;
  final bool isLoading;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height ?? 48,
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: (!isEnabled || isLoading) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color:
                color ??
                (isLoading
                    ? secondaryColor
                    : (isEnabled ? primaryColor : secondaryColor)),
          ),
        ),
        child: isLoading == true
            ? LoadingAnimationWidget.waveDots(
                color: theme.colorScheme.surface,
                size: 28,
              )
            : Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 14,
                  color:
                      color ??
                      (isLoading
                          ? secondaryColor
                          : (isEnabled ? primaryColor : secondaryColor)),
                ),
              ),
      ),
    );
  }
}
