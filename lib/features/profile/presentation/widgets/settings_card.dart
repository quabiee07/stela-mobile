import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });
  final String icon;
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10,
          children: [
            SvgImage(asset: icon, width: 18, height: 18),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: title == 'Log Out' ? orange : null,
              ),
            ),
          ],
        ),
        ?trailing,
      ],
    );
  }
}
