import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

class TextSpeedIndicator extends StatelessWidget {
  const TextSpeedIndicator({super.key});

  static const _labels = ['1x', '1.5x', '2x'];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final track = context.isDarkTheme
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8EC);
    const selectedFill = Colors.white;
    final selectedText =
        context.isDarkTheme ? const Color(0xFF1A1A1A) : onSurface;
    final unselectedText = context.mutedText;

    return BlocBuilder<ReadingPreferencesCubit, ReadingPreferencesState>(
      buildWhen: (prev, curr) => prev.textSpeed != curr.textSpeed,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: List.generate(_labels.length, (index) {
              final selected = state.speedIndex == index;
              return Clickable(
                onPressed: () => context
                    .read<ReadingPreferencesCubit>()
                    .setTextSpeedIndex(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _labels[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? selectedText : unselectedText,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
