import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

class SlideAnimationWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  const SlideAnimationWrapper(
      {super.key, required this.child, required this.index});

  @override
  State<SlideAnimationWrapper> createState() => _SlideAnimationWrapperState();
}

class _SlideAnimationWrapperState extends State<SlideAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool fav = false;
  double delay = 0;
  @override
  void initState() {
    delay = widget.index * 0.1;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start at the bottom
      end: const Offset(0.0, 0.0), // End at the center
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            Interval(delay.toDouble(), delay + 0.6, curve: Sprung.overDamped),
      ),
    );

    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}
