import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/button.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/features/profile/presentation/manager/edit_profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const String id = '/edit-profile-screen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends CustomState<EditProfileScreen> {
  StreamSubscription<EditProfileEffect>? _effectsSub;

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }

  void _bindEffects(EditProfileCubit cubit) {
    _effectsSub?.cancel();
    _effectsSub = cubit.effects.listen((event) {
      if (!mounted) return;
      switch (event) {
        case EditProfileSavedEffect():
          showSuccess('Profile updated');
          context.pop(true);
        case EditProfileErrorEffect(:final message):
          showError(message);
      }
    });
  }

  Future<void> _showAvatarPicker(EditProfileCubit cubit) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose avatar',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final asset in EditProfileCubit.avatarChoices)
                      Clickable(
                        onPressed: () => Navigator.of(sheetContext).pop(asset),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFF3ABA7),
                          backgroundImage: AssetImage(asset),
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

    if (selected != null) {
      cubit.setAvatarAsset(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CubitScaffold<EditProfileCubit, EditProfileState>(
      create: (_) {
        final cubit = createEditProfileCubit();
        _bindEffects(cubit);
        return cubit;
      },
      backgroundColor: theme.scaffoldBackgroundColor,
      children: (context, cubit, state, theme) {
        return [
          const Gap(8),
          Row(
            children: [
              const PopWidget(),
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const Gap(20),
          Expanded(
            child: !state.isHydrated
                ? const Center(
                    child: CircularProgressIndicator(color: orange),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 52,
                                backgroundColor: const Color(0xFFF3ABA7),
                                backgroundImage: AssetImage(state.avatarAsset),
                              ),
                              const Gap(12),
                              Clickable(
                                onPressed: () => _showAvatarPicker(cubit),
                                child: Text(
                                  'CHANGE AVATAR',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: orange,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(28),
                        _LabeledField(
                          label: 'First name',
                          child: InputField(
                            hint: 'First name',
                            value: state.firstName,
                            inputAction: TextInputAction.next,
                            onChange: cubit.setFirstName,
                          ),
                        ),
                        const Gap(16),
                        _LabeledField(
                          label: 'Last name',
                          child: InputField(
                            hint: 'Last name',
                            value: state.lastName,
                            inputAction: TextInputAction.next,
                            onChange: cubit.setLastName,
                          ),
                        ),
                        const Gap(16),
                        _LabeledField(
                          label: 'Username',
                          child: InputField(
                            hint: 'Username',
                            value: state.username,
                            inputAction: TextInputAction.next,
                            onChange: cubit.setUsername,
                          ),
                        ),
                        const Gap(16),
                        _LabeledField(
                          label: 'Password',
                          child: InputField(
                            hint: 'Password',
                            value: state.password,
                            isPassword: true,
                            inputAction: TextInputAction.next,
                            onChange: cubit.setPassword,
                          ),
                        ),
                        const Gap(16),
                        _LabeledField(
                          label: 'Email',
                          child: InputField(
                            hint: 'Email',
                            value: state.email,
                            inputType: TextInputType.emailAddress,
                            inputAction: TextInputAction.next,
                            onChange: cubit.setEmail,
                          ),
                        ),
                        const Gap(16),
                        _LabeledField(
                          label: 'Phone number',
                          child: InputField(
                            hint: 'Phone number',
                            value: state.phoneNumber,
                            inputType: TextInputType.phone,
                            inputAction: TextInputAction.done,
                            onChange: cubit.setPhoneNumber,
                          ),
                        ),
                        const Gap(32),
                        Button2(
                          title: 'Save',
                          isEnabled: state.canSave,
                          isLoading: state.isSaving,
                          onPressed: cubit.save,
                        ),
                      ],
                    ),
                  ),
          ),
        ];
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.mutedText,
          ),
        ),
        const Gap(8),
        child,
      ],
    );
  }
}
