import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/data/services/notification_service.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_state.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/home.dart';
import 'package:stela_mobile/features/library/presentation/screens/library.dart';
import 'package:stela_mobile/features/library/presentation/widgets/playback_dock.dart';
import 'package:stela_mobile/features/profile/data/services/streak_celebration_store.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/profile.dart';
import 'package:stela_mobile/features/profile/presentation/screens/streak_celebration.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String id = '/dashboard-screen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends CustomState<DashboardScreen>
    with WidgetsBindingObserver {
  HomeCubit? _homeCubit;
  StreamSubscription<HomeEffect>? _homeEffectsSub;
  StreamSubscription<GamificationEffect>? _gamificationEffectsSub;
  StreamSubscription<String>? _fcmTokenSub;
  late final List<Widget> _screens;
  bool _didWarmSecondary = false;
  bool _streakPromptInFlight = false;
  int _lastTabIndex = 0;

  @override
  void onStart() {
    _screens = const [HomeScreen(), LibraryScreen(), ProfileScreen()];
    WidgetsBinding.instance.addObserver(this);
    super.onStart();
  }

  @override
  void onStarted() {
    _homeCubit = context.read<HomeCubit>();
    _lastTabIndex = _homeCubit?.state.selectedIndex ?? 0;
    _homeEffectsSub = _homeCubit?.effects.listen((event) {
      if (event is HomeErrorEffect) {
        showError(event.message);
      }
    });

    _gamificationEffectsSub =
        context.read<GamificationCubit>().effects.listen((event) {
      if (event is GamificationErrorEffect) {
        showError(event.message);
      }
    });

    _homeCubit?.loadStories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warmSecondaryServices());
    });
    super.onStarted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeEffectsSub?.cancel();
    _gamificationEffectsSub?.cancel();
    _fcmTokenSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_maybeShowDailyStreakCelebration());
    }
  }

  Future<void> _warmSecondaryServices() async {
    if (_didWarmSecondary || !mounted) return;
    _didWarmSecondary = true;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    unawaited(context.read<ProfileCubit>().loadProfile(showLoading: false));
    unawaited(context.read<HomeCubit>().loadUserGreeting());
    await context.read<GamificationCubit>().loadGamification();
    if (!mounted) return;

    // Let the first frame settle so CoverPageRoute has a stable navigator.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    unawaited(_maybeShowDailyStreakCelebration());
    unawaited(_registerPushToken());
  }

  /// First open / resume of the day with an active streak → celebration once.
  Future<void> _maybeShowDailyStreakCelebration() async {
    if (!mounted || _streakPromptInFlight) return;
    _streakPromptInFlight = true;
    try {
      final gamification = context.read<GamificationCubit>();
      final streak = gamification.state.streakInfo?.currentStreak ??
          gamification.streakDataForDisplay?.currentStreakDays ??
          0;
      if (streak <= 0) return;

      final store = StreakCelebrationStore();
      if (await store.wasShownToday()) return;
      if (!mounted) return;

      // Claim the day before pushing so a resume can't double-open.
      await store.markShownToday();
      if (!mounted) return;

      final week = GamificationDisplay.thisWeekCompletedWithTodayChecked(
        currentStreak: streak,
        lastReadDate: gamification.state.streakInfo?.lastReadDate,
        sessionCountsByDay: gamification.state.sessionCountsByDay,
        weeklySessionCounts: gamification.state.streakInfo?.weeklySessionCounts,
      );

      await StreakCelebrationScreen.open(
        context,
        streakDays: streak,
        weekCompleted: week,
      );
    } finally {
      _streakPromptInFlight = false;
    }
  }

  Future<void> _registerPushToken() async {
    final notifications = NotificationService();
    _fcmTokenSub ??= notifications.tokenUpdates.listen((_) {
      _homeCubit?.saveToken();
    });
    await notifications.init();
    if (mounted) _homeCubit?.saveToken();
  }

  void _refreshProfileTabIfNeeded(int index) {
    if (index == 2 && _lastTabIndex != 2) {
      unawaited(context.read<ProfileCubit>().loadProfile());
      unawaited(context.read<GamificationCubit>().loadGamification());
    }
    _lastTabIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.selectedIndex != curr.selectedIndex,
      listener: (context, state) {
        _refreshProfileTabIfNeeded(state.selectedIndex);
      },
      buildWhen: (prev, curr) => prev.selectedIndex != curr.selectedIndex,
      builder: (_, state) {
        return PopScope(
          canPop: state.selectedIndex == 0,
          onPopInvokedWithResult: (value, _) async {
            if (!value) {
              context.read<HomeCubit>().setIndex(0);
            }
          },
          child: Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            body: IndexedStack(
              index: state.selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: PlaybackDock(
              selectedIndex: state.selectedIndex,
              currentIndex: state.selectedIndex,
              onTabSelected: (index) {
                context.read<HomeCubit>().setIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}

Widget buildDashboardScreen() {
  return const DashboardScreen();
}
