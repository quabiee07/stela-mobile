import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/library/domain/models/narrator_voice.dart';
import 'package:stela_mobile/features/library/presentation/manager/voice_picker_cubit.dart';

/// Shared male/female narrator picker used in settings and onboarding.
class VoicePickerPanel extends StatelessWidget {
  const VoicePickerPanel({
    super.key,
    this.showTitle = true,
    this.padding = EdgeInsets.zero,
  });

  final bool showTitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<VoicePickerCubit, VoicePickerState>(
      listenWhen: (prev, next) =>
          prev.errorMessage != next.errorMessage && next.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showError(state.errorMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<VoicePickerCubit>();
        final female = state.voices
            .where((v) => v.gender == NarratorGender.female)
            .toList();
        final male = state.voices
            .where((v) => v.gender == NarratorGender.male)
            .toList();

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                Text(
                  'Narrator voice',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(6),
                Text(
                  'Pick a male or female storyteller. Preview when available.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: context.mutedText,
                  ),
                ),
                const Gap(16),
              ],
              _GenderSection(
                title: 'Male voices',
                voices: male,
                selectedVoiceId: state.selectedVoiceId,
                previewingVoiceId: state.previewingVoiceId,
                onSelect: cubit.selectVoice,
                onPreview: cubit.previewVoice,
              ),
              const Gap(20),
              _GenderSection(
                title: 'Female voices',
                voices: female,
                selectedVoiceId: state.selectedVoiceId,
                previewingVoiceId: state.previewingVoiceId,
                onSelect: cubit.selectVoice,
                onPreview: cubit.previewVoice,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GenderSection extends StatelessWidget {
  const _GenderSection({
    required this.title,
    required this.voices,
    required this.selectedVoiceId,
    required this.previewingVoiceId,
    required this.onSelect,
    required this.onPreview,
  });

  final String title;
  final List<NarratorVoice> voices;
  final String selectedVoiceId;
  final String? previewingVoiceId;
  final ValueChanged<String> onSelect;
  final ValueChanged<NarratorVoice> onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.mutedText,
          ),
        ),
        const Gap(10),
        ...voices.map((voice) {
          final selected = voice.id == selectedVoiceId;
          final previewing = voice.id == previewingVoiceId;
          final canPreview =
              voice.previewUrl != null && voice.previewUrl!.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Clickable(
              onPressed: () => onSelect(voice.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? orange.withValues(alpha: 0.08)
                      : context.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? orange : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected ? orange : context.chipFill,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppIcon(
                          AppIcons.voice,
                          size: 20,
                          color: selected ? Colors.white : context.mutedText,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            voice.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: context.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canPreview)
                      Clickable(
                        onPressed: () => onPreview(voice),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: previewing
                                ? orange
                                : context.elevatedSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Center(
                            child: AppIcon(
                              previewing ? AppIcons.stop : AppIcons.play,
                              size: 18,
                              color: previewing ? Colors.white : orange,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        'No preview',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: context.mutedText,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

Future<void> showVoicePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return BlocProvider(
        create: (_) => VoicePickerCubit(),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Gap(10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.softBorder,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: const VoicePickerPanel(),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
