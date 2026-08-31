import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/library/domain/models/narrator_voice.dart';
import 'package:stela_mobile/features/library/presentation/manager/voice_picker_cubit.dart';

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => VoicePickerCubit(),
      child: BlocConsumer<VoicePickerCubit, VoicePickerState>(
        listenWhen: (prev, next) =>
            prev.errorMessage != next.errorMessage && next.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            context.showError(state.errorMessage!);
          }
        },
        builder: (context, state) {
          final cubit = context.read<VoicePickerCubit>();
          final voices = state.voices;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const Gap(12),
                const CustomImage(asset: mascot4, height: 150, width: 95),
                const Gap(12),
                Text(
                  'Which Voice Do You Prefer?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(28),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: voices.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, index) {
                    final voice = voices[index];
                    final selected = voice.id == state.selectedVoiceId;
                    final previewing = voice.id == state.previewingVoiceId;
                    return _VoiceCard(
                      voice: voice,
                      selected: selected,
                      previewing: previewing,
                      previewProgress: previewing ? state.previewProgress : null,
                      onTap: () => cubit.selectAndPreview(voice),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VoiceCard extends StatelessWidget {
  const _VoiceCard({
    required this.voice,
    required this.selected,
    required this.previewing,
    required this.onTap,
    this.previewProgress,
  });

  final NarratorVoice voice;
  final bool selected;
  final bool previewing;
  final double? previewProgress;
  final VoidCallback onTap;

  static const _avatarRadius = 28.0;
  static const _ringSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.mutedText;
    final cardFill = context.isDarkTheme
        ? context.elevatedSurface
        : const Color(0xFFF3F6F9);

    return Clickable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: cardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: _ringSize,
              height: _ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (previewing)
                    SizedBox(
                      width: _ringSize,
                      height: _ringSize,
                      child: CircularProgressIndicator(
                        value: previewProgress,
                        strokeWidth: 2.5,
                        color: orange,
                        backgroundColor: orange.withValues(alpha: 0.18),
                      ),
                    ),
                  CircleAvatar(
                    radius: _avatarRadius,
                    backgroundColor: Color(voice.accentColor),
                    backgroundImage: voice.avatarAsset != null
                        ? AssetImage(voice.avatarAsset!)
                        : null,
                    child: voice.avatarAsset == null
                        ? Text(
                            voice.name.isNotEmpty ? voice.name[0] : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const Gap(10),
            Text(
              voice.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              voice.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: muted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
