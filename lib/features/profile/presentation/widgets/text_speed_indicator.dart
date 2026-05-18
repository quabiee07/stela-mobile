import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';

class TextSpeedIndicator extends StatefulWidget {
  const TextSpeedIndicator({super.key});

  @override
  State<TextSpeedIndicator> createState() => _TextSpeedIndicatorState();
}

class _TextSpeedIndicatorState extends State<TextSpeedIndicator> {
  List<String> speed = ['1x', '1.5x', '2x'];
  int selectedIndex = 0;

  void updateIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 6,
        children: speed.map((speedItem) {
          return Clickable(
            onPressed: () => updateIndex(speed.indexOf(speedItem)),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: selectedIndex == speed.indexOf(speedItem)
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                speedItem,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: grey500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
