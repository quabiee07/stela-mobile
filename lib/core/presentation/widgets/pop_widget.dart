import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class PopWidget extends StatelessWidget {
  const PopWidget({super.key, this.callback});

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onPressed: callback == null
          ? () {
              context.pop();
            }
          : callback!,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: grey100),
        child: SvgImage(asset: arrowLeft, width: 24, height: 24),
      ),
    );
  }
}
