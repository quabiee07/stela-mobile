import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_state.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/continue_reading_list.dart';

class ContinueReadingScreen extends StatefulWidget {
  const ContinueReadingScreen({super.key});

  static const String id = '/continue-reading';

  @override
  State<ContinueReadingScreen> createState() => _ContinueReadingScreenState();
}

class _ContinueReadingScreenState extends CustomState<ContinueReadingScreen> {
  @override
  void onStarted() {
    unawaited(context.read<HomeCubit>().refreshContinueReading());
    super.onStarted();
  }

  @override
  void onPopNext() {
    if (mounted) {
      context.read<HomeCubit>().refreshContinueReading();
    }
    super.onPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final items = state.continueReading
                  .where((item) => !item.isComplete)
                  .toList();
              final isLoading =
                  state.isLoadingStories && items.isEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  Row(
                    children: [
                      const PopWidget(),
                      Expanded(
                        child: Text(
                          'Continue reading',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    items.isEmpty
                        ? 'Stories you start will appear here'
                        : '${items.length} ${items.length == 1 ? 'story' : 'stories'} in progress',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.mutedText,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () =>
                                context.read<HomeCubit>().loadStories(),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(bottom: 24),
                              children: [
                                ContinueReadingList(
                                  items: items,
                                  onStoryTap: (item) => context
                                      .read<HomeCubit>()
                                      .resumeReading(context, item),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
