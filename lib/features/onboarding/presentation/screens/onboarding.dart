import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:stela_mobile/features/auth/presentation/manager/auth_cubit.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/auth/presentation/screens/register.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/onboarding/presentation/manager/onboarding_cubit.dart';
import 'package:sprung/sprung.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String id = '/onboarding-screen';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends CustomState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late final AnimationController _animationController;
  Timer? _timer;
  StreamSubscription<AuthEffect>? _authEffectsSub;

  @override
  void onStart() {
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(vsync: this);
    super.onStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authEffectsSub?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer(OnboardingCubit onboardingCubit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_pageController.hasClients) return;

      final pages = onboardingCubit.state.pages;
      if (pages.isEmpty) return;

      int nextPage = onboardingCubit.state.currentIndex + 1;
      if (nextPage >= pages.length) {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => createOnboardingCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: Builder(
        builder: (context) {
          final onboardingCubit = context.read<OnboardingCubit>();
          final authCubit = context.read<AuthCubit>();

          _authEffectsSub ??= authCubit.effects.listen((event) {
            if (!mounted) return;
            switch (event) {
              case AuthFailureEffect(:final message):
                showError(message);
              case AuthSuccessEffect():
                onboardingCubit.markOnboardingSeen();
                context.pushNamedAndClear(DashboardScreen.id);
                showSuccess('Login successful');
              case AuthPasswordResetEffect():
                break;
            }
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_timer == null) _startTimer(onboardingCubit);
          });

          return BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (_, onboardingState) {
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
                          const Gap(77),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: List.generate(
                              onboardingState.pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Sprung.underDamped,
                                width: onboardingState.currentIndex == index
                                    ? 38
                                    : 16,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: onboardingState.currentIndex == index
                                      ? Colors.black
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ),
                          const Gap(26),
                          Text(
                            onboardingState
                                .pages[onboardingState.currentIndex].title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: onboardingCubit.setIndex,
                              itemCount: onboardingState.pages.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Center(
                                    child: CustomImage(
                                      asset: onboardingState.pages[index].image,
                                      width: 345,
                                      height: 345,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const Gap(38),
                                Button2(
                                  title: 'Get Started',
                                  onPressed: () {
                                    onboardingCubit.markOnboardingSeen();
                                    context.pushNamed(RegisterScreen.id);
                                  },
                                ),
                                const Gap(16),
                                BlocBuilder<AuthCubit, AuthFormState>(
                                  builder: (context, authState) {
                                    return SocialSignUpButton(
                                      isGoogle: true,
                                      text: 'Get started with Google',
                                      isLoading: authState.googleLoading,
                                      onTap: () {
                                        authCubit.signInWithGoogle();
                                      },
                                    );
                                  },
                                ),
                                const Gap(32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: const Color(0xFF5A7080),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        onboardingCubit.markOnboardingSeen();
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
      ),
    );
  }
}
