import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/manager/theme_provider.dart';
import 'package:stela_mobile/core/presentation/widgets/app_playback_overlay.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/features/auth/presentation/screens/forgot_password.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/auth/presentation/screens/register.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';
import 'package:stela_mobile/features/auth/presentation/screens/verify.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/onboarding/presentation/screens/onboarding.dart';
import 'package:stela_mobile/features/onboarding/presentation/screens/splash.dart';
import 'package:toastification/toastification.dart';

class StelaApp extends StatelessWidget {
  const StelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt.get<StoryPlaybackCubit>()),
        BlocProvider.value(value: getIt.get<HomeCubit>()),
        BlocProvider.value(value: getIt.get<GamificationCubit>()),
        BlocProvider.value(value: getIt.get<ReadingPreferencesCubit>()),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (_, provider, __) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: provider.isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: provider.isDark
                  ? const Color(0xFF121212)
                  : Colors.white,
              systemNavigationBarIconBrightness: provider.isDark
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );
          return ToastificationWrapper(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Stela',
              theme: provider.theme,
              darkTheme: provider.darkThemeData,
              themeMode: provider.themeMode,
              navigatorKey: navigator,
              navigatorObservers: [routeObserver],
              builder: (context, child) {
                return AppPlaybackOverlay(child: child);
              },
              initialRoute: SplashScreen.id,
              routes: {
                SplashScreen.id: (context) => const SplashScreen(),
                DashboardScreen.id: (context) => buildDashboardScreen(),
                OnboardingScreen.id: (context) => const OnboardingScreen(),
                StoryDescriptionScreen.id: (context) {
                  final storyId =
                      ModalRoute.of(context)?.settings.arguments as String? ??
                      '';
                  return StoryDescriptionScreen(storyId: storyId);
                },
                // StoryDetailScreen.id: (context) => const StoryDetailScreen(),
                LoginScreen.id: (context) => const LoginScreen(),
                RegisterScreen.id: (context) => const RegisterScreen(),
                VerifyScreen.id: (context) => const VerifyScreen(),
                SetupAccountScreen.id: (context) => const SetupAccountScreen(),
                ForgotPasswordScreen.id: (context) =>
                    const ForgotPasswordScreen(),
                // VerifyAccountScreen.id: (context) => const VerifyAccountScreen(),
                // ChangePasswordScreen.id: (context) => const ChangePasswordScreen(),
                // ResetPasswordScreen.id: (context) => const ResetPasswordScreen(),
                // CompleteInfoScreen.id: (context) => const CompleteInfoScreen(),
                // HomeScreen.id: (context) => const HomeScreen(),
              },
            ),
          );
          },
        ),
      ),
    );
  }
}
