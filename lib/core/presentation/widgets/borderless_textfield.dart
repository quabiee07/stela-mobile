import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/inputfield_state.dart';

class BorderlessTextField extends TextFieldParent {
  const BorderlessTextField({
    super.key,
    required super.onChange,
    required this.title,
    super.value,
    super.isPassword,
    this.hint,
    this.inputFormatters,
    this.error,
  });

  final String title;
  final String? hint;
  final String? error;
  final List<TextInputFormatter>? inputFormatters;

  @override
  TextFieldState<TextFieldParent> createState() => _BorderlessTextFieldState();
}

class _BorderlessTextFieldState extends TextFieldState<BorderlessTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: grey500,
          ),
        ),
        const Gap(18),
        Center(
          child: TextField(
            controller: controller,
            onChanged: widget.onChange,
            focusNode: focus,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize:
                  widget.hint!.contains('email') ||
                      widget.hint!.contains('password')
                  ? 24
                  : 40,
              fontWeight: FontWeight.w600,
            ),
            obscureText: isPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),

              filled: false,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: widget.hint,

              suffix: widget.isPassword
                  ? Clickable(
                      onPressed: () => setState(() {
                        isPassword = !isPassword;
                      }),
                      child: Container(
                        width: 50,
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          isPassword ? 'Show' : 'Hide',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: const Color(0xff777777),
                          ),
                        ),
                      ),
                    )
                  : null,

              errorText: widget.error,
              errorStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: Colors.red,
              ),
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: grey300,
              ),
            ),
            inputFormatters: widget.inputFormatters,
          ),
        ),
      ],
    );
  }
}
