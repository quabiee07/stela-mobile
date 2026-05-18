import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/social_sign_up_button.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = "/login-screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends CustomState<LoginScreen> {
  AuthProvider? _provider;

  @override
  void onStarted() {
    _provider?.listen((event) {
      if (event is String) {
        showError(event);
      } else if (event is auth.UserCredential) {
        context.pushNamedAndClear(DashboardScreen.id);
        showSuccess("Login successful");
      }
    });
    super.onStarted();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: AuthProvider(),
      children: (provider, theme) {
        _provider ??= provider;
        final state = provider.state;
        return [
          PopWidget(),
          const Gap(16),
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
            onChange: (value) => provider.setEmail(value),
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
            onChange: (value) => provider.setPassword(value),
            isPassword: true,
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Forgot Password?",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: orange,
                ),
              ),
            ],
          ),
          const Gap(40),
          Button2(
            title: provider.loading ? 'Logging in...' : 'Log In',
            isLoading: provider.loading,
            onPressed: () async {},
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
            onTap: () async {
              provider.signInWithGoogle();
            },
          ),
          const Gap(24),
        ];
      },
    );
  }
}
