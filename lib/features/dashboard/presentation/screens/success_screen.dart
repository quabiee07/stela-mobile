import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });
  final String title;
  final String image;
  final String description;
  final String buttonText;
  final Function() onPressed;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: orange,
      body: Stack(
        children: [
          Positioned(top: 50, left: -10, child: SvgImage(asset: leftPolygon)),
          Align(
            alignment: Alignment.topCenter,
            child: SvgImage(asset: middlePolygon, fit: BoxFit.cover),
          ),
          Positioned(top: 50, right: -10, child: SvgImage(asset: rightPolygon)),
          Positioned(
            top: 170,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  CustomImage(
                        asset: widget.image,
                        height: 213,
                        width: 244,
                        fit: BoxFit.cover,
                      )
                      .animate()
                      .shimmer()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: Offset(0, 1), end: Offset(1, 1)),
                  const Gap(50),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(18),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(70),
                  Clickable(
                    onPressed: () {
                      widget.onPressed();
                    },
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: whiteGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            widget.buttonText,
                            style: const TextStyle(
                              color: black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(28),
                  Clickable(
                    onPressed: () {
                      context.pop();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
