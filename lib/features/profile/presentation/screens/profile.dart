import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/edit_profile.dart';
import 'package:stela_mobile/features/profile/presentation/screens/settings.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/badge_grid.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/stats_card.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/streak_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String id = '/profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends CustomState<ProfileScreen> {
  Future<void> _openEditProfile() async {
    final updated = await context.push(const EditProfileScreen());
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  ImageProvider _avatarImage() {
    final avatarUrl = cachedUser?.avatarUrl ?? '';
    if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      return AssetImage(avatarUrl);
    }
    return const AssetImage(femaleAvatar);
  }

  String _formatReadTime(double hours) {
    if (hours <= 0) return '0';
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '${minutes}m';
    }
    final rounded = (hours * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? '${rounded.round()}h'
        : '${rounded}h';
  }

  @override
  Widget build(BuildContext context) {
    return CubitScaffold<ProfileCubit, AccountState>(
      create: (_) => createProfileCubit(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      children: (context, profileCubit, profileState, theme) {
        return [
          const Gap(16),
          Expanded(
            child: BlocBuilder<GamificationCubit, GamificationState>(
              builder: (context, gamification) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: context.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 12,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFFF3ABA7),
                                  backgroundImage: _avatarImage(),
                                ),
                                Clickable(
                                  onPressed: () {
                                    context.push(const SettingsScreen());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: context.elevatedSurface,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: AppIcon(
                                      AppIcons.settings,
                                      size: 24,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Clickable(
                              onPressed: _openEditProfile,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cachedUser?.name ?? 'Maya the Reader',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(4),
                                  AppIcon(
                                    AppIcons.edit,
                                    size: 16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppIcon(
                                  AppIcons.star,
                                  color: amber,
                                  size: 20,
                                ),
                                const Gap(4),
                                Text(
                                  'Level ${gamification.level} ${cachedUser?.title ?? ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: context.mutedText,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  '${gamification.totalXp} XP',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: orange,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            SizedBox(
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: gamification.levelProgressFraction
                                        .clamp(0.0, 1.0),
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      minHeight: 8,
                                      backgroundColor: context.softBorder,
                                      valueColor:
                                          const AlwaysStoppedAnimation(orange),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Gap(4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${(gamification.levelProgressFraction * 100).round()}% to level ${gamification.level + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.mutedText,
                                ),
                              ),
                            ),
                            const Gap(24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: context.elevatedSurface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  StatsCard(
                                    emoji: '📗',
                                    value: '${gamification.storiesRead}',
                                    label: 'Stories',
                                  ),
                                  StatsCard(
                                    emoji: '🕐',
                                    value: _formatReadTime(
                                      gamification.readTimeHours,
                                    ),
                                    label: 'Read time',
                                  ),
                                  StatsCard(
                                    emoji: '🏅',
                                    value:
                                        '${context.read<GamificationCubit>().badgeProgress.where((b) => b.unlocked).length}',
                                    label: 'Badges',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      BadgeGrid(
                        badges: context.read<GamificationCubit>().badgeProgress,
                        collapsedCount: context.read<GamificationCubit>().badgeProgress.where((b) => b.unlocked).length,
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
                      StreakCard(
                        streakData: context
                            .read<GamificationCubit>()
                            .streakDataForDisplay,
                        freezeAvailable:
                            gamification.streakInfo?.freezeAvailable ?? false,
                        isFrozen:
                            gamification.streakInfo?.streakStatus == 'frozen',
                        onActivateFreeze: () async {
                          await context
                              .read<GamificationCubit>()
                              .activateFreeze();
                        },
                      ),
                      const Gap(120),
                    ]
                        .animate(interval: 50.ms)
                        .fade(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.1, curve: Curves.easeOut),
                  ),
                );
              },
            ),
          ),
        ];
      },
    );
  }
}
