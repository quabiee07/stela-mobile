import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/scrollable_widget.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_cubit.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static const String id = '/verify-screen';

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final otpFieldController = OtpFieldControllerV2();
  String _otp = '';

  @override
  void dispose() {
    // OtpFieldControllerV2 has no dispose API; clear references only.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CubitScaffold<AuthCubit, AuthFormState>(
      create: (_) => AuthCubit(),
      children: (context, cubit, state, theme) {
        return [
          const Gap(42),
          Text('Confirm 5 Digit code', style: theme.textTheme.titleLarge),
          const Gap(4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'A 5 digit code has been sent to your email. '
                      'Enter the code to continue.',
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
                onChanged: (value) {
                  setState(() => _otp = value);
                },
                onCompleted: (value) {
                  setState(() => _otp = value);
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
            isEnabled: _otp.length == 5,
            isLoading: state.loading,
            onPressed: () {
              // OTP verification is not wired to a backend yet —
              // do not skip into setup without a real verify API.
              showError(
                'Email verification is not available yet. '
                'Please continue from login after confirming your email.',
              );
            },
          ),
          const Gap(44),
        ];
      },
    );
  }
}
