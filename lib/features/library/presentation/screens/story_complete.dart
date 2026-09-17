import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/dashboard.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/success_screen.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';

class StoryCompleteScreen extends StatefulWidget {
  const StoryCompleteScreen({
    super.key,
    required this.storyTitle,
    required this.chaptersCompleted,
    this.currentStreak,
    this.xpEarned,
  });

  static const String id = '/story-complete';

  final String storyTitle;
  final int chaptersCompleted;
  final int? currentStreak;
  final int? xpEarned;

  static Future<void> open(
    BuildContext context, {
    required String storyTitle,
    required int chaptersCompleted,
    int? currentStreak,
    int? xpEarned,
  }) {
    return Navigator.of(context).push<void>(
      CoverPageRoute(
        settings: const RouteSettings(name: id),
        builder: (_) => StoryCompleteScreen(
          storyTitle: storyTitle,
          chaptersCompleted: chaptersCompleted,
          currentStreak: currentStreak,
          xpEarned: xpEarned,
        ),
      ),
    );
  }

  @override
  State<StoryCompleteScreen> createState() => _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends State<StoryCompleteScreen> {
  var _shared = false;

  String get _description {
    final lines = <String>[
      'You finished "${widget.storyTitle}".',
      '${widget.chaptersCompleted} chapters listened',
    ];
    if (widget.xpEarned != null && widget.xpEarned! > 0) {
      lines.add('+${widget.xpEarned} XP');
    }
    if (widget.currentStreak != null && widget.currentStreak! > 0) {
      lines.add('${widget.currentStreak}-day reading streak');
    }
    return lines.join('\n');
  }

  Future<void> _share() async {
    if (_shared) return;
    final success = await context.read<GamificationCubit>().shareAchievement();
    if (!mounted) return;
    if (success) {
      setState(() => _shared = true);
      context.showSuccess(
        'Shared! +${LevelProgress.shareXpReward} XP added to your profile.',
      );
    }
  }

  void _backToLibrary() {
    context.read<HomeCubit>().openLibraryTab();
    Navigator.of(context).popUntil((route) {
      return route.settings.name == DashboardScreen.id || route.isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, GamificationState>(
      buildWhen: (prev, curr) => prev.isSharing != curr.isSharing,
      builder: (context, state) {
        return SuccessScreen(
          image: pinkCheck,
          title: 'Story\ncomplete!',
          description: _description,
          buttonText: _shared
              ? 'SHARED +${LevelProgress.shareXpReward} XP'
              : 'SHARE +${LevelProgress.shareXpReward} XP',
          isButtonLoading: state.isSharing,
          isButtonEnabled: !_shared,
          onPressed: _share,
          secondaryText: 'Back to library',
          onSecondaryPressed: _backToLibrary,
        );
      },
    );
  }
}
