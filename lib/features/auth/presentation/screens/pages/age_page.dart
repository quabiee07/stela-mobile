import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:gif_view/gif_view.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';
import 'package:stela_mobile/core/presentation/widgets/borderless_textfield.dart';

class AgePage extends StatefulWidget {
  const AgePage({super.key});

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const Gap(20),
          GifView.asset(favStoryGif, height: 143, width: 102, frameRate: 60),
          const Gap(8),
          Text(
            "How old are you?",
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24),
          ),
          const Gap(36),
          Consumer<AuthProvider>(
            builder: (_, provider, _) {
              final state = provider.state;
              return BorderlessTextField(
                onChange: (value) {
                  provider.setAge(value);
                },
                title: "Age",
                hint: "Enter your age",
                value: state.age,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
