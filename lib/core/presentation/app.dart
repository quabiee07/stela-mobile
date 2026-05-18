import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/manager/theme_provider.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';
import 'package:stela_mobile/features/auth/presentation/screens/verify.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';
import 'package:stela_mobile/features/onboarding/presentation/screens/onboarding.dart';
import 'package:stela_mobile/features/onboarding/presentation/screens/splash.dart';
import 'package:toastification/toastification.dart';

class StelaApp extends StatelessWidget {
  const StelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (_, provider, __) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: provider.isDark
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
              navigatorKey: navigator,
              navigatorObservers: [routeObserver],
              initialRoute: SplashScreen.id,
              routes: {
                SplashScreen.id: (context) => const SplashScreen(),
                DashboardScreen.id: (context) => const DashboardScreen(),
                OnboardingScreen.id: (context) => const OnboardingScreen(),
                StoryDescriptionScreen.id: (context) =>
                    const StoryDescriptionScreen(),
                StoryDetailScreen.id: (context) => const StoryDetailScreen(),
                LoginScreen.id: (context) => const LoginScreen(),
                VerifyScreen.id: (context) => const VerifyScreen(),
                SetupAccountScreen.id: (context) => const SetupAccountScreen(),
                // ForgotPasswordScreen.id: (context) =>
                //     const ForgotPasswordScreen(),
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
    );
  }
}
