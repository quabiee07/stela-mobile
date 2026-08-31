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
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/slide_animation_wrapper.dart';
import 'package:stela_mobile/features/auth/presentation/manager/setup_cubit.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/age_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/name_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/story_type_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/voice_page.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/success_screen.dart';

class SetupAccountScreen extends StatefulWidget {
  const SetupAccountScreen({super.key});
  static const String id = '/setup-account';

  @override
  State<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends CustomState<SetupAccountScreen> {
  int currentIndex = 0;
  final _controller = PageController(initialPage: 0);
  StreamSubscription<SetupEffect>? _effectsSub;

  final pages = const [
    NamePage(),
    AgePage(),
    StoryTypePage(),
    VoicePage(),
  ];

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CubitScaffold<SetupCubit, SetupState>(
      create: (context) {
        final cubit = createSetupCubit();
        _effectsSub?.cancel();
        _effectsSub = cubit.effects.listen((event) {
          if (!mounted) return;
          switch (event) {
            case SetupErrorEffect(:final message):
              showError(message);
            case SetupCompleteEffect(:final result):
              context.push(
                SuccessScreen(
                  image: pinkCheck,
                  title: 'Your journey\nawaits!',
                  description:
                      'Dear hero your stories are being\nprepared for you, see you at home',
                  buttonText: 'Go to Home',
                  onPressed: () {
                    context.pushNamedAndClear(DashboardScreen.id);
                  },
                ),
              );
          }
        });
        return cubit;
      },
      canPop: currentIndex == 0,
      padding: 16,
      // backgroundColor:,
      children: (context, cubit, state, theme) {
        return [
          const Gap(24),
          Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (index) {
              return Container(
                width: index == currentIndex ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == currentIndex ? orange : grey400,
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          ),
          const Gap(20),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              children: pages,
            ),
          ),
        ];
      },
      bottomSheet: BlocBuilder<SetupCubit, SetupState>(
        builder: (context, state) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SlideAnimationWrapper(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Button2(
                  title: currentIndex == pages.length - 1
                      ? 'Complete'
                      : 'Continue',
                  isLoading: state.isSubmitting,
                  onPressed: () {
                    if (currentIndex < pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      context.read<SetupCubit>().completeOnboarding();
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
