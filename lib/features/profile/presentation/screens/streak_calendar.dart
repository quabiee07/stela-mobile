import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Gap(8),
              Align(alignment: Alignment.centerLeft, child: PopWidget()),
              const Gap(12),
              Expanded(
                child: BlocBuilder<GamificationCubit, GamificationState>(
                  builder: (context, state) {
                    final activeDays = context
                        .read<GamificationCubit>()
                        .activeStreakDates;
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _MonthHeader(
                          month: _visibleMonth,
                          onPrev: () => _shiftMonth(-1),
                          onNext: () => _shiftMonth(1),
                        ),
                        const Gap(16),
                        _MonthGrid(
                          month: _visibleMonth,
                          activeDays: activeDays,
                        ),
                        const Gap(24),
                        Divider(color: context.softBorder, height: 1),
                        const Gap(24),
                        Text(
                          DateFormat('MMMM yyyy').format(nextMonth),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(16),
                        _MonthGrid(month: nextMonth, activeDays: activeDays),
                        const Gap(40),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Clickable(
          onPressed: onPrev,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: AppIcon(AppIcons.arrowLeft, size: 22, color: orange),
          ),
        ),
        Clickable(
          onPressed: onNext,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: AppIcon(AppIcons.arrowRight, size: 22, color: orange),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.activeDays});

  final DateTime month;
  final Set<DateTime> activeDays;

  static const _weekendIndexes = {5, 6};

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedText;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - DateTime.monday;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < GamificationDisplay.weekdayLabels.length; i++)
              Expanded(
                child: Text(
                  GamificationDisplay.weekdayLabels[i].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _weekendIndexes.contains(i) ? orange : muted,
                  ),
                ),
              ),
          ],
        ),
        const Gap(12),
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: _dayFor(leading, daysInMonth, row * 7 + col),
                      isWeekend: _weekendIndexes.contains(col),
                      isActive: _isActive(
                        _dayFor(leading, daysInMonth, row * 7 + col),
                      ),
                      isToday: _isSameDay(
                        _dayFor(leading, daysInMonth, row * 7 + col),
                        todayOnly,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  DateTime? _dayFor(int leading, int daysInMonth, int index) {
    final dayNum = index - leading + 1;
    if (dayNum < 1 || dayNum > daysInMonth) return null;
    return DateTime(month.year, month.month, dayNum);
  }

  bool _isActive(DateTime? day) {
    if (day == null) return false;
    return activeDays.contains(day);
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isWeekend,
    required this.isActive,
    required this.isToday,
  });

  final DateTime? day;
  final bool isWeekend;
  final bool isActive;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const SizedBox(height: 40);
    }

    final muted = context.mutedText;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final number = '${day!.day}';

    if (isActive) {
      return Center(
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isWeekend
                ? orange.withValues(alpha: 0.7)
                : (isToday ? onSurface : muted),
          ),
        ),
      ),
    );
  }
}
