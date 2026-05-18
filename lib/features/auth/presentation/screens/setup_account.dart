import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gif_view/gif_view.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/slide_animation_wrapper.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/age_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/name_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/story_type_page.dart';
import 'package:stela_mobile/features/auth/presentation/screens/pages/credential_page.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/success_screen.dart';

class SetupAccountScreen extends StatefulWidget {
  const SetupAccountScreen({super.key});
  static const String id = "/setup-account";

  @override
  State<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends CustomState<SetupAccountScreen> {
  AuthProvider? _provider;
  int currentIndex = 0;
  final _controller = PageController(initialPage: 0);

  final pages = [CredentialPage(), NamePage(), AgePage(), StoryTypePage()];

  @override
  void didChangeDependencies() {
    GifView.preFetchImage(const AssetImage(ageGif));
    GifView.preFetchImage(const AssetImage(favStoryGif));
    super.didChangeDependencies();
  }

  @override
  void onStarted() {
    _provider?.listen((event) {
      if (event is String) {
        showError(event);
      } else if (event is UserModel) {
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
    super.onStarted();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: AuthProvider(),
      canPop: currentIndex == 0,
      padding: 16,
      backgroundColor: const Color(0xFFFCFCFC),
      children: (provider, theme) {
        _provider ??= provider;
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
              children: List.generate(pages.length, (index) => pages[index]),
            ),
          ),
        ];
      },
      bottomSheet: Consumer<AuthProvider>(
        builder: (context, provider, _) {
          _provider ??= provider;
          final state = provider.state;
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
                  isEnabled: state.isValidated,
                  title: currentIndex == pages.length - 1
                      ? "Create Account"
                      : "Continue",
                  isLoading: provider.loading,
                  onPressed: () {
                    if (currentIndex < pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      provider.createAccount();
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
