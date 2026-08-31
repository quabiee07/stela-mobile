import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/core/presentation/widgets/scrollable_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/social_sign_up_button.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_cubit.dart';
import 'package:stela_mobile/features/auth/presentation/screens/forgot_password.dart';
import 'package:stela_mobile/features/auth/presentation/screens/register.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = "/login-screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<AuthEffect>? _effectSub;

  Future<void> _onEffect(AuthEffect effect) async {
    if (effect is AuthFailureEffect) {
      showError(effect.message);
      return;
    }
    if (effect is AuthSuccessEffect) {
      if (!mounted) return;
      if (effect.requiresSetup) {
        context.pushNamedAndClear(SetupAccountScreen.id);
      } else {
        context.pushNamedAndClear(DashboardScreen.id);
      }
      showSuccess("Login successful");
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
          const Gap(16),
          ScrollableWidget(
            children: [
              Text(
                "Welcome back",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                "Enter your details below to login to your Stela account.",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: grey,
                ),
              ),
              const Gap(20),
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
              const Gap(20),
              Text(
                "Password",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(8),
              InputField(
                hint: 'Enter password',
                value: state.password,
                error: state.passwordError,
                onChange: cubit.setPassword,
                isPassword: true,
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => context.pushNamed(ForgotPasswordScreen.id),
                    child: Text(
                      "Forgot Password?",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: orange,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(40),
              Button2(
                title: state.loading ? 'Logging in...' : 'Log In',
                isLoading: state.loading,
                onPressed: cubit.signIn,
              ),
              const Gap(16),
              Row(
                children: [
                  const Expanded(child: Divider(color: grey300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: theme.textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider(color: grey300)),
                ],
              ),
              const Gap(16),
              SocialSignUpButton(
                isGoogle: true,
                isLoading: state.googleLoading,
                text: 'Sign in with Google',
                color: grey200,
                onTap: cubit.signInWithGoogle,
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5A7080),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamed(RegisterScreen.id),
                    child: Text(
                      'Register',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(55),
        ];
      },
    );
  }
}
