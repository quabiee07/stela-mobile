import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_provider.dart';
import 'package:stela_mobile/features/profile/presentation/screens/settings.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/stats_card.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/streak_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String id = "/profile-screen";
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: ProfileProvider(),
      backgroundColor: const Color(0xFFF7F7F8),
      padding: 16,
      children: (provider, theme) {
        return [
          // Row(
          //   spacing: 10,
          //   children: [
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   height: 36,
          //   decoration: BoxDecoration(
          //     color: theme.colorScheme.surface,
          //     borderRadius: BorderRadius.circular(100),
          //   ),
          // ),
          //   ],
          // ),
          const Gap(16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 12,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                    const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Color(0xFFF3ABA7),
                                      backgroundImage: AssetImage(femaleAvatar),
                                    ),

                                    Clickable(
                                      onPressed: () {
                                        context.push(SettingsScreen());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: SvgImage(
                                          asset: setting,
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cachedUser?.name ?? 'Maya the Reader',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const Gap(4),
                                    SvgImage(
                                      asset: edit,
                                      width: 16,
                                      height: 16,
                                    ),
                                  ],
                                ),

                                const Gap(6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rate_rounded,
                                      color: amber,
                                      size: 20,
                                    ),
                                    Gap(4),
                                    Text(
                                      'Level ${cachedUser?.level} ${cachedUser?.title}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: grey500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(35),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: grey100,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      StatsCard(
                                        emoji: '📗',
                                        value:
                                            '${cachedUser?.stats.storiesRead}',
                                        label: 'Stories',
                                      ),
                                      StatsCard(
                                        emoji: '🕐',
                                        value:
                                            '${cachedUser?.stats.readTimeHours.toDouble()}',
                                        label: 'Read time',
                                      ),
                                      StatsCard(
                                        emoji: '🏅',
                                        value:
                                            '${cachedUser?.stats.totalBadges}',
                                        label: 'Badges',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'My Badges',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: (cachedUser?.badges ?? [])
                                .map(
                                  (badge) => Column(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 53,
                                        decoration: BoxDecoration(
                                          color: grey100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            badge.iconAsset,
                                            style: const TextStyle(
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(6),
                                      Text(
                                        badge.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: grey500,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                          const Gap(16),
                          Text(
                            'Reading Streak',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(12),
                          StreakCard(streakData: cachedUser?.streakData),
                          const Gap(120),
                        ]
                        .animate(interval: 50.ms)
                        .fade(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.1, curve: Curves.easeOut),
              ),
            ),
          ),
        ];
      },
    );
  }
}
