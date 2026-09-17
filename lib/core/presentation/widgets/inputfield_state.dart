import 'package:flutter/material.dart';

import '../utils/custom_state.dart';

abstract class TextFieldParent extends StatefulWidget {
  const TextFieldParent({
    required this.onChange,
    this.value,
    super.key,
    this.isPassword = false,
  });
  final String? value;

  final bool isPassword;

  final void Function(String) onChange;

  @override
  TextFieldState<TextFieldParent> createState();
}

abstract class TextFieldState<T extends TextFieldParent> extends CustomState<T> {
  late TextEditingController controller;
  final focus = FocusNode();
  var isFocus = false;
  String value = '';
  bool isPassword = false;

  @override
  void onStart() {
    controller = TextEditingController(text: widget.value);
    isPassword = widget.isPassword;
    focus.addListener(_onFocusChange);
    super.onStart();
  }

  @override
  void onStarted() {
    controller.addListener(_onControllerChanged);
    super.onStarted();
  }

  void _onControllerChanged() {
    value = controller.text;
    widget.onChange(controller.text);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      isFocus = focus.hasFocus;
    });
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value;
    if (next != null && next != controller.text) {
      controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void onDestroy() {
    focus.removeListener(_onFocusChange);
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    focus.dispose();
    super.onDestroy();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
