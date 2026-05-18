import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
// import 'package:lottie/lottie.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  State<EmptyState> createState() => _EmptyState();
}

class _EmptyState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            // child: Lottie.asset(
            //   '',
            //   controller: _controller,
            //   onLoaded: (composition) {
            //     _controller
            //       ..duration = composition.duration
            //       ..forward()
            //       ..repeat();
            //   },
            // ),
          ),
          const Gap(16),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 17,
              color: textColorLight,
            ),
          ),
          const Gap(8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
