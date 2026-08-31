import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/manager/theme_provider.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/settings_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/settings_card.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/text_size_indicator.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/text_speed_indicator.dart';
import 'package:stela_mobile/features/library/presentation/widgets/voice_picker_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _audioOn = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return CubitScaffold<SettingsCubit, SettingsState>(
      create: (_) => createSettingsCubit(),
      children: (context, cubit, state, theme) {
        return [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PopWidget(),
                        Text(
                          'Settings',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: context.cardSurface,
                    ),
                    child: Column(
                      spacing: 8,
                      children: [
                        SettingsCard(
                          icon: AppIcons.text,
                          title: 'Text Speed',
                          trailing: TextSpeedIndicator(),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.text,
                          title: 'Text Size',
                          trailing: TextSizeIndicator(),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.voice,
                          title: 'Narrator Voice',
                          trailing: Clickable(
                            onPressed: () => showVoicePickerSheet(context),
                            child: Row(
                              children: [
                                Text(
                                  'Choose',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const AppIcon(AppIcons.arrowRight, size: 20),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.voice,
                          title: 'Audio On',
                          trailing: CupertinoSwitch(
                            value: _audioOn,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) {
                              setState(() {
                                _audioOn = value;
                              });
                            },
                          ),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.notification,
                          title: 'Reading Reminder',
                          trailing: CupertinoSwitch(
                            value: state.isReminderEnabled,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) {
                              cubit.setDailyReminderValue(value);
                            },
                          ),
                        ),
                        if (state.isReminderEnabled) ...[
                          Divider(
                            thickness: .6,
                            height: .6,
                            color: context.divider,
                          ),
                          SettingsCard(
                            icon: AppIcons.notification,
                            title: 'Reminder time',
                            trailing: Clickable(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: state.reminderHour,
                                    minute: 0,
                                  ),
                                );
                                if (picked != null) {
                                  await cubit.setReminderHour(picked.hour);
                                }
                              },
                              child: Text(
                                TimeOfDay(
                                  hour: state.reminderHour,
                                  minute: 0,
                                ).format(context),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.flash,
                          title: 'Streak Freeze',
                          trailing: CupertinoSwitch(
                            value: state.streakFreezeActivated,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) async {
                              await cubit.activateStreakFreeze(value);
                              if (value && context.mounted) {
                                await context
                                    .read<GamificationCubit>()
                                    .loadGamification();
                              }
                            },
                          ),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: themeProvider.isDark
                              ? AppIcons.moon
                              : AppIcons.sun,
                          title: themeProvider.isDark
                              ? 'Dark Mode'
                              : 'Light Mode',
                          trailing: CupertinoSwitch(
                            value: !themeProvider.isDark,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: themeProvider.setLightMode,
                          ),
                        ),
                        Divider(
                          thickness: .6,
                          height: .6,
                          color: context.divider,
                        ),
                        SettingsCard(
                          icon: AppIcons.global,
                          title: 'Language',
                          trailing: Clickable(
                            onPressed: () {
                              // context.push(LanguageScreen());
                            },
                            child: Row(
                              children: [
                                Text(
                                  'English',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                AppIcon(AppIcons.arrowRight, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: context.cardSurface,
                    ),
                    child: Clickable(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          builder: (sheetContext) {
                            return BlocProvider(
                              create: (_) => createProfileCubit(),
                              child: BlocBuilder<ProfileCubit, AccountState>(
                                builder: (profileContext, profileState) {
                                  return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: IntrinsicHeight(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 50,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        150,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const Gap(16),
                                            Center(
                                              child: Text(
                                                'Sign Out',
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      fontSize: 20,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                              ),
                                            ),
                                            const Gap(8),
                                            Center(
                                              child: Text(
                                                'Are you sure you want to sign out? You can login again once you do',
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 16,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(alpha: .5),
                                                    ),
                                              ),
                                            ),
                                            const Gap(40),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Clickable(
                                                    onPressed: () {
                                                      sheetContext.pop();
                                                    },
                                                    child: Container(
                                                      height: 54,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: grey200,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Cancel',
                                                          style: theme
                                                              .textTheme
                                                              .displayLarge
                                                              ?.copyWith(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Gap(16),
                                                Expanded(
                                                  child: Button2(
                                                    title: 'Sign out',
                                                    isLoading:
                                                        profileState.isLoggingOut,
                                                    onPressed: () {
                                                      // Use profileContext (under BlocProvider),
                                                      // not sheetContext (above it).
                                                      profileContext
                                                          .read<ProfileCubit>()
                                                          .clearUserSession(
                                                            profileContext,
                                                          );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Gap(10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: SettingsCard(icon: AppIcons.logout, title: 'Log Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }
}
