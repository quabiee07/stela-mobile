import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_provider.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/settings_card.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/text_size_indicator.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/text_speed_indicator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ProfileProvider? _provider;
  bool _audioOn = false;
  bool _readingReminder = false;
  bool _streakFreeze = false;
  bool _lightMode = false;

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: ProfileProvider(),
      children: (provider, theme) {
        _provider ??= provider;
        // final state = provider.state;

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
                      color: grey100,
                    ),
                    child: Column(
                      spacing: 8,
                      children: [
                        SettingsCard(
                          icon: text,
                          title: 'Text Speed',
                          trailing: TextSpeedIndicator(),
                        ),
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: text,
                          title: 'Text Size',
                          trailing: TextSizeIndicator(),
                        ),
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: voice,
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
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: notification,
                          title: 'Reading Reminder',
                          trailing: CupertinoSwitch(
                            value: _readingReminder,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) {
                              setState(() {
                                _readingReminder = value;
                              });
                            },
                          ),
                        ),
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: zap,
                          title: 'Streak Freeze',
                          trailing: CupertinoSwitch(
                            value: _streakFreeze,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) {
                              setState(() {
                                _streakFreeze = value;
                              });
                            },
                          ),
                        ),
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: sun,
                          title: 'Light Mode',
                          trailing: CupertinoSwitch(
                            value: _lightMode,
                            activeTrackColor: orange,
                            inactiveTrackColor: grey400,
                            onChanged: (value) {
                              setState(() {
                                _lightMode = value;
                              });
                            },
                          ),
                        ),
                        const Divider(
                          thickness: .6,
                          height: .6,
                          color: greyDivider,
                        ),
                        SettingsCard(
                          icon: global,
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
                                SvgImage(
                                  asset: arrowRight,
                                  height: 20,
                                  width: 20,
                                ),
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
                      color: grey100,
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
                          builder: (context) {
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
                                            color: theme.colorScheme.onSurface,
                                            borderRadius: BorderRadius.circular(
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
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                        ),
                                      ),
                                      const Gap(8),
                                      Center(
                                        child: Text(
                                          'Are you sure you want to sign out? You can login again once you do',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: 16,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(.5),
                                              ),
                                        ),
                                      ),
                                      const Gap(40),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Clickable(
                                              onPressed: () {
                                                context.pop();
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
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Cancel',
                                                    style: theme
                                                        .textTheme
                                                        .displayLarge
                                                        ?.copyWith(
                                                          fontSize: 14,
                                                          // color: Colors.white,
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
                                              isLoading: provider.loading,
                                              onPressed: () {
                                                provider.clearUserSession(
                                                  context,
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
                        );
                      },
                      child: SettingsCard(icon: logout, title: 'Log Out'),
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
