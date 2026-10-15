import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.image,
    this.illustration,
    this.description = '',
    this.footer,
    this.secondaryText,
    this.onSecondaryPressed,
    this.isButtonLoading = false,
    this.isButtonEnabled = true,
    this.titleStyle,
  }) : assert(
         image != null || illustration != null,
         'Provide an image asset or an illustration widget.',
       );

  static const String id = '/success-screen';

  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  /// Asset path for the hero image. Ignored when [illustration] is set.
  final String? image;
  final Widget? illustration;
  final String description;
  final Widget? footer;
  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;
  final bool isButtonLoading;
  final bool isButtonEnabled;
  final TextStyle? titleStyle;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
    String? image,
    Widget? illustration,
    String description = '',
    Widget? footer,
    String? secondaryText,
    VoidCallback? onSecondaryPressed,
    bool isButtonLoading = false,
    bool isButtonEnabled = true,
    TextStyle? titleStyle,
    String routeName = id,
  }) {
    return Navigator.of(context).push<void>(
      CoverPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (_) => SuccessScreen(
          title: title,
          buttonText: buttonText,
          onPressed: onPressed,
          image: image,
          illustration: illustration,
          description: description,
          footer: footer,
          secondaryText: secondaryText,
          onSecondaryPressed: onSecondaryPressed,
          isButtonLoading: isButtonLoading,
          isButtonEnabled: isButtonEnabled,
          titleStyle: titleStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: orange,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: orange,
        body: Stack(
          children: [
            const Positioned(
              top: 50,
              left: -10,
              child: SvgImage(asset: leftPolygon),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: SvgImage(asset: middlePolygon, fit: BoxFit.cover),
            ),
            const Positioned(
              top: 50,
              right: -10,
              child: SvgImage(asset: rightPolygon),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const Gap(48),
                            illustration ??
                                CustomImage(
                                      asset: image!,
                                      height: 213,
                                      width: 244,
                                      fit: BoxFit.cover,
                                    )
                                    .animate()
                                    .shimmer()
                                    .fadeIn(duration: 500.ms)
                                    .scale(
                                      begin: const Offset(0, 1),
                                      end: const Offset(1, 1),
                                    ),
                            const Gap(25),
                            if (title.isNotEmpty)
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style:
                                    titleStyle ??
                                    theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            if (description.isNotEmpty) ...[
                              const Gap(18),
                              Text(
                                description,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            if (footer != null) ...[const Gap(32), footer!],
                          ],
                        ),
                      ),
                    ),
                    Clickable(
                      isEnabled: isButtonEnabled && !isButtonLoading,
                      onPressed: onPressed,
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
                            child: isButtonLoading
                                ? LoadingAnimationWidget.waveDots(
                                    color: orange,
                                    size: 28,
                                  )
                                : Text(
                                    buttonText,
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
                    if (secondaryText != null &&
                        onSecondaryPressed != null) ...[
                      const Gap(16),
                      Clickable(
                        onPressed: onSecondaryPressed!,
                        child: Text(
                          secondaryText!,
                          style: const TextStyle(
                            color: white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Gap(24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
