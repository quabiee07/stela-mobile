import 'package:flutter/material.dart';

/// Full-screen cover that is a real page route (not a dialog or sheet).
/// The floating mini player stays hidden while this is on top.
///
/// Heroes are disabled so celebration/success pushes cannot collide with the
/// playback cover Hero still mounted under the previous route.
class CoverPageRoute<T> extends MaterialPageRoute<T> {
  CoverPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        builder: (context) => HeroMode(enabled: false, child: builder(context)),
        fullscreenDialog: true,
      );
}
