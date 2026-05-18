import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/core/presentation/widgets/social_sign_up_button.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/auth/presentation/screens/setup_account.dart';
import 'package:stela_mobile/features/onboarding/presentation/manager/onboarding_provider.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String id = "/onboarding-screen";

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends CustomState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  OnboardingProvider? _provider;
  AuthProvider? _authProvider;
  late PageController _pageController;
  late final AnimationController _animationController;
  Timer? _timer;

  @override
  void onStart() {
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(vsync: this);
    super.onStart();
  }

  @override
  void onStarted() {
    _provider?.init();

    _startTimer();
    _authProvider?.listen((event) {
      if (event is String) {
        showError(event);
      } else if (event is auth.UserCredential) {
        _provider?.setOnboarding();
        context.pushNamedAndClear(DashboardScreen.id);
        showSuccess("Login successful");
      }
    });
    super.onStarted();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_provider == null || _provider!.state.onboardingPages.isEmpty) return;
      if (!_pageController.hasClients) return;

      int nextPage = _provider!.state.currentIndex + 1;
      if (nextPage >= _provider!.state.onboardingPages.length) {
        nextPage = 0;
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Sprung.overDamped,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      builder: (context, child) {
        return Consumer2<OnboardingProvider, AuthProvider>(
          builder: (_, provider, authProvider, _) {
            _provider ??= provider;
            _authProvider ??= authProvider;
            final state = provider.state;
            return Scaffold(
              body: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(gradient: stelaGradient),
                child: Stack(
                  children: [
                    Positioned(
                      top: 70,
                      left: -5,
                      child: SvgImage(asset: bookOpen, height: 654),
                    ),
                    Column(
                      children: [
                        Gap(77),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: List.generate(
                            state.onboardingPages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Sprung.underDamped,
                              width: state.currentIndex == index ? 38 : 16,
                              height: 5,
                              decoration: BoxDecoration(
                                color: state.currentIndex == index
                                    ? Colors.black
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                        Gap(26),
                        Text(
                          state.onboardingPages[state.currentIndex].title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (value) {
                              provider.setIndex(value);
                            },
                            itemCount: state.onboardingPages.length,
                            physics: const BouncingScrollPhysics(),
                            // shinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
                                  child: CustomImage(
                                    asset: state.onboardingPages[index].image,
                                    width: 345,
                                    height: 345,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            // bottom: 16,
                          ),
                          child: Column(
                            children: [
                              const Gap(38),
                              Button2(
                                title: 'Get Started',
                                onPressed: () {
                                  provider.setOnboarding();
                                  context.pushNamed(SetupAccountScreen.id);
                                },
                              ),
                              const Gap(16),
                              SocialSignUpButton(
                                isGoogle: true,
                                text: 'Get started with Google',
                                isLoading: authProvider.loading,
                                onTap: () {
                                  
                                  authProvider.signInWithGoogle();
                                },
                              ),
                              const Gap(32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5A7080),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      provider.setOnboarding();
                                      context.pushNamed(LoginScreen.id);
                                    },
                                    child: Text(
                                      'Log In',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              // ],
                              const Gap(55),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
