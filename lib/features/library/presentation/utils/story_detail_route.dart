import 'package:flutter/material.dart';

/// Slides the story reader up from the mini-player dock (expand) and back down
/// on pop (collapse).
class StoryDetailPageRoute<T> extends PageRouteBuilder<T> {
  StoryDetailPageRoute({required Widget screen})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slide = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final fade = CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.55, curve: Curves.easeOut),
              reverseCurve: const Interval(0.45, 1, curve: Curves.easeIn),
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(slide),
              child: FadeTransition(opacity: fade, child: child),
            );
          },
        );
}
