import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/scrollable_widget.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static const String id = "/verify-screen";
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  AuthProvider? _provider;
  final otpFieldController = OtpFieldControllerV2();

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: AuthProvider(),
      children: (provider, theme) {
        _provider ??= provider;
        return [
          const Gap(42),
          Text('Confirm 5 Digit code', style: theme.textTheme.titleLarge),
          const Gap(4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'A 5 digit code has been sent to the email ',
                  style: theme.textTheme.titleSmall,
                ),
                TextSpan(
                  text: 'stevedave@gmail.com ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Color(0xFF0063F2),
                  ),
                ),
                TextSpan(
                  text: 'enter code to continue',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const Gap(16),
          ScrollableWidget(
            children: [
              const Gap(64),
              OTPTextFieldV2(
                controller: otpFieldController,
                length: 5,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 58,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                onChanged: (value) {},
                onCompleted: (value) {
                  // provider.setOtp(value);
                  // provider.verifyOtp(email: email);
                },
                cursorColor: midGrey,
                otpFieldStyle: OtpFieldStyle(
                  borderColor: midGrey,
                  enabledBorderColor: midGrey,
                  errorBorderColor: theme.colorScheme.error,
                  backgroundColor: Colors.white,
                  focusBorderColor: orange,
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'DMSans',
                  fontSize: 40,
                  fontWeight: FontWeight.normal,
                ),
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
              ),
              const Gap(32),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'Didn’t get a code? ',
                  style: theme.textTheme.titleSmall,
                  children: [
                    TextSpan(
                      text: 'Resend Code',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Color(0xFF0063F2),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),
            ],
          ),
          Button2(
            title: 'Verify',
            isEnabled: true,
            isLoading: provider.loading,
            onPressed: () {
              context.push(const SetupAccountScreen());
              // provider.verifyOtp(email: email);
            },
          ),
          const Gap(44),
        ];
      },
    );
  }
}
