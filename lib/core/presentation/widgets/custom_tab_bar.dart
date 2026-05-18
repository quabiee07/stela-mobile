import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

class CustomTabBar extends StatefulWidget {
  final int initialIndex;
  final List<String> tabs;
  final List<Widget> children;
  final ValueChanged<int> onTabSelected;

  const CustomTabBar({
    super.key,
    required this.initialIndex,
    required this.tabs,
    required this.onTabSelected,
    required this.children,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        widget.onTabSelected(_controller.index);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent changes the selected index, update controller
    if (widget.initialIndex != _controller.index) {
      _controller.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light gray background
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _controller,
              tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: textGrey,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
              ),
              splashFactory: NoSplash.splashFactory, // disable ripple effect
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              dividerHeight: 0,
            ),
          ),
          const Gap(20),
          Expanded(
            child: TabBarView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}
