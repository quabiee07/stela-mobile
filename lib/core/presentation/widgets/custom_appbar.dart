import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar(
      {super.key,
      required this.isBackIconVisible,
      required this.title,
      this.suffix});
  final bool isBackIconVisible;
  final String title;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.8),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isBackIconVisible
                    ? PopWidget(
                        callback: () {
                          context.pop();
                        },
                      )
                    : const SizedBox(),
              ],
            ),
            Center(
                child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                suffix ??
                    const SizedBox(
                        width: 48), // Reserve space if suffixWidget is null
              ],
            ),
          ],
        ));
  }
}
