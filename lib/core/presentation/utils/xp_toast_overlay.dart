import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stela_mobile/core/presentation/utils/celebration_feedback.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/widgets/xp_toast.dart';

/// Dedicated XP-earned toast — independent of the global snackbar / toastification
/// path in `snack_bar_utils.dart`.
///
/// Uses a single [OverlayEntry] so it never rebuilds the app shell, and plays
/// haptics + (optional) SFX without interrupting story playback audio.
class XpToastOverlay {
  XpToastOverlay._();

  static OverlayEntry? _entry;

  static const Duration _visibleFor = Duration(milliseconds: 2400);
  static const Duration _exitDuration = Duration(milliseconds: 320);

  /// Shows the XP toast above the current route. Non-blocking.
  static void show(BuildContext context, {required int xp}) {
    if (xp <= 0) return;

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        navigator.currentState?.overlay;
    if (overlay == null) return;

    dismiss();

    unawaited(CelebrationFeedback.xp());

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;
        // Sit above story playback controls without covering them.
        final bottom = bottomInset + 108;

        return IgnorePointer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: _XpToastLifecycle(
                xp: xp,
                visibleFor: _visibleFor,
                exitDuration: _exitDuration,
                onFinished: () {
                  if (identical(_entry, entry)) {
                    _entry?.remove();
                    _entry = null;
                  }
                },
              ),
            ),
          ),
        );
      },
    );

    _entry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
  }
}

/// Handles enter → hold → exit so the overlay entry can remove itself cleanly.
class _XpToastLifecycle extends StatefulWidget {
  const _XpToastLifecycle({
    required this.xp,
    required this.visibleFor,
    required this.exitDuration,
    required this.onFinished,
  });

  final int xp;
  final Duration visibleFor;
  final Duration exitDuration;
  final VoidCallback onFinished;

  @override
  State<_XpToastLifecycle> createState() => _XpToastLifecycleState();
}

class _XpToastLifecycleState extends State<_XpToastLifecycle> {
  var _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.visibleFor, _beginExit);
  }

  void _beginExit() {
    if (!mounted || !_visible) return;
    setState(() => _visible = false);
    _timer = Timer(widget.exitDuration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return XpToast(xp: widget.xp)
        .animate(target: _visible ? 1 : 0)
        .fade(
          duration: widget.exitDuration,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.35,
          end: 0,
          duration: widget.exitDuration,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: widget.exitDuration,
          curve: Curves.easeOutBack,
        );
  }
}
