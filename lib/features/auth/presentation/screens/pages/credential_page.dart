import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';

class CredentialPage extends StatefulWidget {
  const CredentialPage({super.key});

  @override
  State<CredentialPage> createState() => _CredentialPageState();
}

class _CredentialPageState extends CustomState<CredentialPage> {
  AuthProvider? _provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AuthProvider>(
      builder: (_, provider, _) {
        _provider ??= provider;
        final state = provider.state;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let’s create your account",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                "Enter your email address and create a secure password to get started.",
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

              const Gap(20),
              Text(
                "Confirm Password",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(8),
              InputField(
                hint: 'Confirm password',
                value: state.confirmPassword,
                error: state.confirmPasswordError,
                onChange: (value) => provider.setConfirmPassword(value),
                isPassword: true,
              ),
              const Gap(40),
            ],
          ),
        );
      },
    );
  }
}
