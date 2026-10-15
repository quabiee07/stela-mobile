import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/widgets/social_sign_up_button.dart';

bool get supportsAppleSignIn => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.googleLoading,
    required this.appleLoading,
    required this.onGoogle,
    required this.onApple,
    this.googleText = 'Sign in with Google',
    this.appleText = 'Sign in with Apple',
    this.color,
  });

  final bool googleLoading;
  final bool appleLoading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final String googleText;
  final String appleText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialSignUpButton(
          isGoogle: true,
          isLoading: googleLoading,
          text: googleText,
          color: color,
          onTap: googleLoading || appleLoading ? null : onGoogle,
        ),
        if (supportsAppleSignIn) ...[
          const Gap(16),
          SocialSignUpButton(
            isGoogle: false,
            isLoading: appleLoading,
            text: appleText,
            color: color,
            onTap: googleLoading || appleLoading ? null : onApple,
          ),
        ],
      ],
    );
  }
}
