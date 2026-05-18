import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/inputfield_state.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class InputField extends TextFieldParent {
  const InputField({
    required this.hint,
    super.key,
    required super.onChange,
    super.value,
    super.isPassword,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.error,
    this.isClear = false,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.done,
    this.minLines = 1,
    this.onAction,
    this.inputFormatters,
  });

  final String? prefix;
  final Widget? prefixIcon;
  final Widget? suffix;

  final bool readOnly;

  final int maxLines;
  final int? maxLength;
  final String? error;
  final String hint;
  final bool isClear;

  final TextInputType inputType;

  final TextInputAction inputAction;

  final VoidCallback? onAction;

  final int minLines;

  final List<TextInputFormatter>? inputFormatters;

  @override
  TextFieldState<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends TextFieldState<InputField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(),
      ),
      child: TextField(
        controller: controller,
        focusNode: focus,
        readOnly: widget.readOnly,
        showCursor: true,
        obscureText: isPassword,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onAction,
        textInputAction: widget.inputAction,
        style: theme.textTheme.labelLarge,
        inputFormatters: widget.inputFormatters ?? [],
        cursorColor: textColorLight,
        onTapOutside: (_) {
          focus.unfocus();
        },

        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: grey500,
          ),

          errorText: widget.error,
          prefixIcon: widget.prefix == null
              ? widget.prefixIcon
              : CustomImage(asset: widget.prefix!),
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
              : widget.isClear && value.isNotEmpty
              ? Clickable(
                  onPressed: () {
                    controller.clear();
                  },
                  child: SvgImage(
                    asset: '',
                    width: 24,
                    height: 24,
                    color: theme.colorScheme.onSurface.withValues(alpha: .7),
                    fit: BoxFit.scaleDown,
                  ),
                )
              : widget.suffix,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: red),
          ),
        ),
      ),
    );
  }
}
