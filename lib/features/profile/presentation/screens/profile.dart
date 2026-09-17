import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/profile_avatar.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/edit_profile.dart';
import 'package:stela_mobile/features/profile/presentation/screens/settings.dart';
import 'package:stela_mobile/features/profile/presentation/screens/streak_calendar.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/badge_grid.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/stats_card.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/streak_card.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String id = '/profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends CustomState<ProfileScreen> {
  StreamSubscription<ProfileEffect>? _profileEffectsSub;
  late final VideoPlayerController _controller;

  @override
  void onStarted() {
    final cubit = context.read<ProfileCubit>();
    _profileEffectsSub = cubit.effects.listen((event) {
      if (event is ProfileErrorEffect) {
        showError(event.message);
      }
    });
    unawaited(cubit.loadProfile());
    super.onStarted();
  }

  @override
  void dispose() {
    _profileEffectsSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final gamificationCubit = context.read<GamificationCubit>();
    final homeCubit = context.read<HomeCubit>();
    final updated = await context.push(const EditProfileScreen());
    if (updated == true && mounted) {
      // Edit already wrote cache + Firestore; avoid GET /auth/profile wiping
      // a freshly uploaded photo URL before the API catches up.
      profileCubit.hydrateFromCache();
      unawaited(homeCubit.loadUserGreeting());
      unawaited(gamificationCubit.loadGamification());
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              Expanded(
                child: BlocBuilder<ProfileCubit, AccountState>(
                  builder: (context, profile) {
                    return BlocBuilder<GamificationCubit, GamificationState>(
                      builder: (context, gamification) {
                        return RefreshIndicator(
                          color: orange,
                          onRefresh: () async {
                            final profileCubit = context.read<ProfileCubit>();
                            final gamificationCubit = context
                                .read<GamificationCubit>();
                            await profileCubit.refreshProfile();
                            await gamificationCubit.loadGamification();
                          },
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: context.cardSurface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                spacing: 12,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                    ),
                                                  ),
                                                  ProfileAvatar(
                                                    avatarUrl:
                                                        profile.avatarUrl,
                                                    radius: 50,
                                                    progress: gamification
                                                        .levelProgressFraction,
                                                  ),
                                                  Clickable(
                                                    onPressed: () {
                                                      context.push(
                                                        const SettingsScreen(),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: context
                                                            .elevatedSurface,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              100,
                                                            ),
                                                      ),
                                                      child: AppIcon(
                                                        AppIcons.settings,
                                                        size: 24,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Gap(8),
                                              Clickable(
                                                onPressed: _openEditProfile,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      profile.name.isEmpty
                                                          ? 'Reader'
                                                          : profile.name,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface,
                                                          ),
                                                    ),
                                                    const Gap(4),
                                                    AppIcon(
                                                      AppIcons.edit,
                                                      size: 16,
                                                      color: orange,
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
                                                    'Level ${gamification.level} ${profile.title}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: context.mutedText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Gap(24),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      context.elevatedSurface,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Row(
                                                  children: [
                                                    StatsCard(
                                                      asset: book,
                                                      value:
                                                          '${gamification.storiesRead}',
                                                      label: 'Stories',
                                                    ),
                                                    StatsCard(
                                                      asset: clockk,
                                                      value: _formatReadTime(
                                                        gamification
                                                            .readTimeHours,
                                                      ),
                                                      label: 'Read time',
                                                    ),
                                                    StatsCard(
                                                      asset: warranty,
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
                                          badges: context
                                              .read<GamificationCubit>()
                                              .badgeProgress,
                                        ),
                                        const Gap(16),
                                        Text(
                                          'Reading Streak',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
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
                                              gamification
                                                  .streakInfo
                                                  ?.freezeAvailable ??
                                              false,
                                          isFrozen:
                                              gamification
                                                  .streakInfo
                                                  ?.streakStatus ==
                                              'frozen',
                                          onActivateFreeze: () async {
                                            await context
                                                .read<GamificationCubit>()
                                                .activateFreeze();
                                          },
                                          onOpenCalendar: () {
                                            context.push(
                                              const StreakCalendarScreen(),
                                            );
                                          },
                                        ),
                                        const Gap(120),
                                      ]
                                      .animate(interval: 50.ms)
                                      .fade(
                                        duration: 400.ms,
                                        curve: Curves.easeOut,
                                      )
                                      .slideY(
                                        begin: 0.1,
                                        curve: Curves.easeOut,
                                      ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
