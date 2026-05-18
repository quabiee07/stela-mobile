import 'package:flutter/material.dart';

class ScrollableWidget extends StatelessWidget {
  const ScrollableWidget(
      {super.key,
      required this.children,
      this.padding = 0,
      this.alignment = CrossAxisAlignment.start});

  final List<Widget> children;

  final double padding;

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: alignment,
          children: children,
        ),
      ),
    );
  }
}
