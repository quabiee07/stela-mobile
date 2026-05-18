import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:sprung/sprung.dart';

class BottomNavBarItem {
  BottomNavBarItem({this.icon, required this.text});

  String? icon;
  String text;

  static List<BottomNavBarItem> get items => [
    BottomNavBarItem(text: 'Home', icon: home),
    BottomNavBarItem(text: 'Library', icon: library),
    BottomNavBarItem(text: 'Profile', icon: user),
  ];
}

class BottomNavBar extends StatefulWidget {
  BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.currentIndex,
    this.items,
    this.height = 70.0,
    this.iconSize = 24.0,
    this.onTabSelected,
  }) {
    assert(items?.length == 2 || items?.length == 3 || items?.length == 4);
  }

  final List<BottomNavBarItem>? items;
  final double? height;
  final double? iconSize;
  final ValueChanged<int>? onTabSelected;
  final int selectedIndex;
  final int currentIndex;

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _BottomNavBarState(selectedIndex: selectedIndex);
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  var selectedIndex = 0;

  _BottomNavBarState({required this.selectedIndex});

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> items = List.generate(widget.items!.length, (int index) {
      return _buildTabItem(
        item: widget.items![index],
        index: index,
        onPressed: (index) {
          widget.onTabSelected!(index);
          setState(() {
            selectedIndex = index;
          });
        },
        theme: theme,
      );
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: widget.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: items,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BottomNavBarItem item,
    required ThemeData theme,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    return Clickable(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed(index);
      },
      child: AnimatedContainer(
        height: widget.height,
        duration: const Duration(milliseconds: 500),
        curve: Sprung.underDamped,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.5).animate(
            CurvedAnimation(parent: _controller, curve: Sprung.overDamped),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgImage(
                  asset: item.icon!,
                  height: widget.iconSize,
                  color: widget.currentIndex == index
                      ? orange
                      : const Color(0xFFCAD5E2),
                ),
                Text(
                  item.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: widget.currentIndex == index
                        ? orange
                        : const Color(0xFFCAD5E2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
