import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprung/sprung.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/onboarding/presentation/manager/splash_cubit.dart';
import 'package:stela_mobile/features/onboarding/presentation/screens/onboarding.dart';

class SplashScreen extends StatelessWidget {
  static const String id = "/splash-screen";
  const SplashScreen({super.key});

  void _navigate(BuildContext context, SplashDestination destination) {
    switch (destination) {
      case SplashDestination.onboarding:
        context.pushReplacement(const OnboardingScreen());
      case SplashDestination.login:
        context.pushNamedReplacement(LoginScreen.id);
      case SplashDestination.setup:
        context.pushNamedReplacement(SetupAccountScreen.id);
      case SplashDestination.dashboard:
        context.pushNamedAndClear(DashboardScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: BlocListener<SplashCubit, SplashDestination?>(
        listener: (context, destination) {
          if (destination != null) {
            _navigate(context, destination);
          }
        },
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(gradient: stelaGradient),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                      child: CustomImage(
                        asset: stelaLogo,
                        width: 135,
                        height: 115,
                      ),
                    )
                    .animate(delay: 1500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: 1.0,
                      end: 0.0,
                      curve: Sprung.underDamped,
                      duration: 1500.ms,
                    ),
                Text(
                      'Stela',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        color: Colors.white,
                      ),
                    )
                    .animate(delay: 500.ms)
                    .fadeIn(
                      duration: 1000.ms,
                      curve: Curves.fastLinearToSlowEaseIn,
                    )
                    .slideY(
                      begin: 0.5,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Sprung.overDamped,
                    )
                    .then(delay: 500.ms)
                    .shimmer(
                      duration: 1800.ms,
                      color: Colors.white.withValues(alpha: .5),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
