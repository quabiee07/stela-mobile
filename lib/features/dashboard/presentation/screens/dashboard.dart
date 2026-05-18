import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_provider.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/home.dart';
import 'package:stela_mobile/features/library/presentation/screens/library.dart';
import 'package:stela_mobile/features/profile/presentation/screens/profile.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_provider.dart' as stela_profile;
import 'package:stela_mobile/core/presentation/widgets/animations/streak_notification_dialog.dart' as stela_dialog;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String id = "/dashboard-screen";

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends CustomState<DashboardScreen> {
  HomeProvider? _provider;
  late List<Widget> _screens;

  @override
  void onStart() {
    _screens = [HomeScreen(), LibraryScreen(), ProfileScreen()];
    super.onStart();
  }

  @override
  void onStarted() async {
    if (mounted) {
      await getCachedUser().then((user) async {
        if (user != null) {
          setState(() {
            cachedUser = user;
          });
          
          final profileProvider = stela_profile.ProfileProvider();
          await profileProvider.evaluateStreakOnOpen(context);
          if (profileProvider.state.streakMessage != null && mounted) {
            stela_dialog.StreakNotificationDialog.show(context, profileProvider.state.streakMessage!);
          }
        }
      });
    }

    super.onStarted();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (_, provider, __) {
          _provider ??= provider;
          final state = provider.state;
          return PopScope(
            canPop: state.selectedIndex == 0,
            onPopInvokedWithResult: (value, _) async {
              if (!value) {
                provider.setIndex(0);
              }
            },
            child: Scaffold(
              extendBody: true,
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  Expanded(child: _screens.elementAt(state.selectedIndex)),
                ],
              ),
              bottomNavigationBar: BottomNavBar(
                selectedIndex: state.selectedIndex,
                currentIndex: state.selectedIndex,
                onTabSelected: (index) {
                  provider.setIndex(index);
                },
                items: [
                  for (final tabItem in BottomNavBarItem.items)
                    BottomNavBarItem(text: tabItem.text, icon: tabItem.icon),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
