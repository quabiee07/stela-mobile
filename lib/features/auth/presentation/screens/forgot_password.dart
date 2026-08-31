import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const String id = "/forgot-password-screen";

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  StreamSubscription<AuthEffect>? _effectSub;

  void _onEffect(AuthEffect effect) {
    if (effect is AuthFailureEffect) {
      showError(effect.message);
      return;
    }
    if (effect is AuthPasswordResetEffect) {
      if (!mounted) return;
      showSuccess(
        "Password reset email sent successfully. Please check your inbox.",
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _effectSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CubitScaffold<AuthCubit, AuthFormState>(
      create: (_) {
        final cubit = AuthCubit();
        _effectSub?.cancel();
        _effectSub = cubit.effects.listen(_onEffect);
        return cubit;
      },
      children: (context, cubit, state, theme) {
        return [
          const PopWidget(),
          const Gap(16),
          Text(
            "Forgot Password",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            "Enter your email address below to receive a password reset link.",
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: grey,
            ),
          ),
          const Gap(40),
          Text(
            "Email",
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(8),
          InputField(
            hint: 'Enter email address',
            value: state.email,
            error: state.emailError,
            onChange: cubit.setEmail,
          ),
          const Gap(40),
          Button2(
            title: state.loading ? 'Sending...' : 'Reset Password',
            isLoading: state.loading,
            onPressed: cubit.resetPassword,
          ),
          const Gap(55),
        ];
      },
    );
  }
}
