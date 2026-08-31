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
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String id = '/dashboard-screen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends CustomState<DashboardScreen> {
  HomeCubit? _homeCubit;
  StreamSubscription<HomeEffect>? _homeEffectsSub;
  StreamSubscription<GamificationEffect>? _gamificationEffectsSub;
  late final List<Widget> _screens;
  bool _didWarmSecondary = false;

  @override
  void onStart() {
    _screens = const [HomeScreen(), LibraryScreen(), ProfileScreen()];
    super.onStart();
  }

  @override
  void onStarted() {
    _homeCubit = context.read<HomeCubit>();
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
    _homeEffectsSub?.cancel();
    _gamificationEffectsSub?.cancel();
    super.dispose();
  }

  Future<void> _warmSecondaryServices() async {
    if (_didWarmSecondary || !mounted) return;
    _didWarmSecondary = true;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    unawaited(context.read<GamificationCubit>().loadGamification());

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    unawaited(
      NotificationService().init().then((_) {
        if (mounted) _homeCubit?.saveToken();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      // Only tab index belongs to this shell — story loads must not rebuild it.
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
                if (index == 2) {
                  context.read<GamificationCubit>().loadGamification();
                }
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
