import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/slide_animation_wrapper.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_provider.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';

class StoryDescriptionScreen extends StatefulWidget {
  const StoryDescriptionScreen({super.key});
  static const String id = '/story-description';

  @override
  State<StoryDescriptionScreen> createState() => _StoryDescriptionScreenState();
}

class _StoryDescriptionScreenState extends State<StoryDescriptionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = context.getArgs<Story>();
    return ProviderWidget(
      padding: 0,
      provider: LibraryProvider(),
      children: (provider, theme) {
        return [
          Expanded(
            child: Stack(
              children: [
                // Background Gradient Blur
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) {
                    double offset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0;
                    double progress = (offset / 250).clamp(0.0, 1.0);
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 450,
                      child: Opacity(
                        opacity: 0.8 * (1 - progress),
                        child: CustomImage(asset: blurBg, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),

                // Scrollable Content
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Space for the animated header
                          const SizedBox(height: 460),

                          // Description Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Clickable(
                                  onPressed: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: grey100,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: orange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description Text
                          const Gap(16),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 32,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: grey100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                story.fullText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Animated Fading Texts (Scrolls up and out)
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) {
                    double offset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0;
                    double progress = (offset / 150).clamp(0.0, 1.0);

                    return Positioned(
                      top: 360 - offset,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Opacity(
                          opacity: 1.0 - progress,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  story.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                story.author,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const Gap(8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rate_rounded,
                                    color: amber,
                                    size: 16,
                                  ),
                                  const Gap(6),
                                  const Text(
                                    '4.5 (1.4k)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Solid White Header taking effect on scroll
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) {
                    double offset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0;
                    double progress = (offset / 100).clamp(
                      0.0,
                      1.0,
                    ); // Fades in quickly mask

                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height:
                          105, // accommodate top safe area padding and app bar heights securely
                      child: Opacity(
                        opacity: progress,
                        child: Container(color: Colors.white),
                      ),
                    );
                  },
                ),

                // Animated Image and App Bar Buttons
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) {
                    double offset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0;
                    double progress = (offset / 200).clamp(0.0, 1.0);

                    double imageInitialWidth = 220;
                    double imageFinalWidth = 40;
                    double imageWidth =
                        imageInitialWidth -
                        (imageInitialWidth - imageFinalWidth) * progress;

                    double imageInitialHeight = 280;
                    double imageFinalHeight = 40;
                    double imageHeight =
                        imageInitialHeight -
                        (imageInitialHeight - imageFinalHeight) * progress;

                    double imageInitialTop = 60;
                    double imageFinalTop = 16;
                    double imageTop =
                        imageInitialTop -
                        (imageInitialTop - imageFinalTop) * progress;

                    double imageInitialLeft =
                        (screenWidth(context) - imageInitialWidth) / 2;
                    double imageFinalLeft = 64;

                    double imageLeft =
                        imageInitialLeft -
                        (imageInitialLeft - imageFinalLeft) * progress;

                    return SafeArea(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // App Bar Backgrounds/Buttons
                          Positioned(
                            top: 12,
                            left: 16,
                            child: Clickable(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey100,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 16,
                            child: Clickable(
                              onPressed: () {},
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey100,
                                ),
                                child: const SvgImage(
                                  asset: menu,
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),

                          // Shrunk Title (appears next to small image)
                          if (progress > 0.6)
                            Positioned(
                              top: 22,
                              left: imageFinalLeft + imageFinalWidth + 12,
                              right: 64,
                              child: Opacity(
                                opacity: ((progress - 0.6) * 2.5).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Text(
                                  story.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                          // Animated Cover Image
                          Positioned(
                            top: imageTop,
                            left: imageLeft,
                            width: imageWidth,
                            height: imageHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                16 - (8 * progress),
                              ),
                              child: CustomImage(
                                asset: story.coverImage,
                                width: imageWidth,
                                height: imageHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ];
      },
      bottomSheet: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SlideAnimationWrapper(
          index: 1,
          child: Clickable(
            onPressed: () {
              context.pushNamed(StoryDetailScreen.id, args: story);
            },
            child: Container(
              height: 80,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 18,
                left: 16,
                right: 16,
              ),
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Start Reading',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
