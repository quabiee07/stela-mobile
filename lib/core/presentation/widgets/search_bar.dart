import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        spacing: 8,
        children: [
          SvgImage(asset: 'searchOutline'),
           Text(
              'Search for restaurant or dishes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    );
  }
}
