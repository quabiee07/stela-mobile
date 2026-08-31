import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/widgets/borderless_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/auth/presentation/manager/setup_cubit.dart';

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
          CustomImage(asset: mascot2, height: 150, width: 95),
          const Gap(8),
          Text(
            "How old are you?",
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24),
          ),
          const Gap(36),
          BlocBuilder<SetupCubit, SetupState>(
            builder: (context, state) {
              return BorderlessTextField(
                onChange: (value) {
                  context.read<SetupCubit>().setAge(value);
                },
                title: 'Age',
                hint: 'Enter your age',
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
