import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class FeaturedStoriesCarousel extends StatefulWidget {
  const FeaturedStoriesCarousel({
    super.key,
    required this.stories,
    required this.onTap,
  });

  final List<StorySummary> stories;
  final ValueChanged<StorySummary> onTap;

  @override
  State<FeaturedStoriesCarousel> createState() => _FeaturedStoriesCarouselState();
}

class _FeaturedStoriesCarouselState extends State<FeaturedStoriesCarousel> {
  PageController? _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _ensureController();
    _scheduleAutoPlay();
  }

  @override
  void didUpdateWidget(covariant FeaturedStoriesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stories.isEmpty) {
      _stopAutoPlay();
      _disposeController();
      _currentPage = 0;
      return;
    }

    _ensureController();

    final storiesChanged = oldWidget.stories.length != widget.stories.length ||
        oldWidget.stories.map((s) => s.storyId).join() !=
            widget.stories.map((s) => s.storyId).join();

    if (storiesChanged) {
      _currentPage = 0;
      _schedulePageReset();
    }

    _scheduleAutoPlay();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _disposeController();
    super.dispose();
  }

  void _ensureController() {
    if (widget.stories.isEmpty) return;
    _pageController ??= PageController();
  }

  void _disposeController() {
    _pageController?.dispose();
    _pageController = null;
  }

  void _schedulePageReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pageController == null) return;
      if (!_pageController!.hasClients) return;
      _pageController!.jumpToPage(0);
    });
  }

  void _scheduleAutoPlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _restartAutoPlay();
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _restartAutoPlay() {
    _stopAutoPlay();
    if (widget.stories.length <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final controller = _pageController;
      if (!mounted || controller == null || !controller.hasClients) return;

      final nextPage = (_currentPage + 1) % widget.stories.length;
      controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty || _pageController == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final controller = _pageController!;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            key: ValueKey(widget.stories.map((story) => story.storyId).join()),
            controller: controller,
            itemCount: widget.stories.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final story = widget.stories[index];
              return GestureDetector(
                onTap: () => widget.onTap(story),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FeaturedCard(story: story, theme: theme),
                ),
              );
            },
          ),
        ),
        if (widget.stories.length > 1) ...[
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.stories.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? orange : grey300,
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.story,
    required this.theme,
  });

  final StorySummary story;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cover = story.coverImageUrl;
    final hasNetworkCover = cover.startsWith('http');

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: grey200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasNetworkCover)
            CachedImage(asset: cover, fit: BoxFit.cover)
          else
            CustomImage(
              asset: cover.isNotEmpty ? cover : boyDragon,
              fit: BoxFit.cover,
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Featured today',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Gap(12),
                Text(
                  story.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    Text(
                      story.tags,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      story.readTime,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Container(
                  width: 130,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'Start Reading',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
