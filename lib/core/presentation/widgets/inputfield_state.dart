import 'package:flutter/material.dart';

import '../utils/custom_state.dart';

abstract class TextFieldParent extends StatefulWidget {
  const TextFieldParent({required this.onChange, this.value, super.key, this.isPassword = false});
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
    controller.addListener(() {
      value = controller.text;
      if(mounted){
        setState(() {

        });
      }

      widget.onChange(controller.text);
    });
    super.onStarted();
  }

  void _onFocusChange() {
    setState(() {
      isFocus = focus.hasFocus;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (widget.value != controller.text && widget.value != null) {
      if (mounted) {
        controller.text = widget.value ?? '';
      }
    }
    return const Placeholder();
  }
}



