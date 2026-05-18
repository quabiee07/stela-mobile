import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/borderless_textfield.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});
  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const Gap(20),
          CustomImage(asset: nameBunny, height: 150, width: 95),
          const Gap(12),
          Text(
            "What's your name, hero?",
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24),
          ),
          const Gap(36),
          Consumer<AuthProvider>(
            builder: (_, provider, _) {
              final state = provider.state;
              return BorderlessTextField(
                onChange: (value) {
                  provider.setName(value);
                },
                title: "Name",
                hint: "Enter your name",
                value: state.name,
              );
            },
          ),
        ],
      ),
    );
  }
}
