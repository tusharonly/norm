import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:norm/src/utils/haptic.dart';
import 'package:provider/provider.dart';

class ActivityCalender extends StatefulWidget {
  final HabitModel habit;

  const ActivityCalender({
    super.key,
    required this.habit,
  });

  @override
  State<ActivityCalender> createState() => _ActivityCalenderState();
}

class _ActivityCalenderState extends State<ActivityCalender> {
  late DateTime _currentMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  void _navigateMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        1,
      );
    });
    AppHaptic.buttonPressed();
  }

  void _jumpToToday() {
    setState(() {
      _currentMonth = DateTime(_today.year, _today.month, 1);
    });
    AppHaptic.buttonPressed();
  }

  List<DateTime> _getCalendarDays() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );

    // Get the first day of the week (Sunday = 0, Monday = 1, etc.)
    final firstWeekDay = firstDayOfMonth.weekday % 7;

    // Start from the first Sunday of the calendar view
    final calendarStart = firstDayOfMonth.subtract(
      Duration(days: firstWeekDay),
    );

    // Generate 42 days (6 weeks) for the calendar
    return List.generate(
      42,
      (index) => calendarStart.add(Duration(days: index)),
    );
  }

  bool _isDateInCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month && date.year == _currentMonth.year;
  }

  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  bool _isHabitCompleted(DateTime date, HabitModel habit) {
    return habit.history.contains(date.onlydate);
  }

  void _toggleHabitCompletion(DateTime date) {
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    habitsProvider.toggleHabitDone(
      id: widget.habit.id,
      date: date,
    );
    AppHaptic.successPressed();
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _getCalendarDays();

    return Consumer<HabitsProvider>(
      builder: (context, habitsProvider, child) {
        // Get the updated habit from the provider
        final currentHabit =
            habitsProvider.habits[widget.habit.id] ?? widget.habit;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with month/year and navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentMonth.year == _today.year
                          ? DateFormat('MMMM').format(_currentMonth)
                          : DateFormat('MMMM yyyy').format(_currentMonth),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _navigateMonth(-1),
                          icon: Icon(
                            LucideIcons.chevronLeft,
                            color: AppColors.primaryTextColor,
                          ),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isDateInCurrentMonth(DateTime.now())
                              ? null
                              : () => _navigateMonth(1),
                          icon: Icon(
                            LucideIcons.chevronRight,
                            color: _isDateInCurrentMonth(DateTime.now())
                                ? AppColors.primaryTextColor.withAlpha(150)
                                : AppColors.primaryTextColor,
                          ),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Weekday headers
                Row(
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map(
                        (day) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 8),

                // Calendar grid
                Column(
                  spacing: 4,
                  children: List.generate(
                    6,
                    (weekIndex) {
                      return Row(
                        spacing: 4,
                        children: List.generate(7, (dayIndex) {
                          final dayDate =
                              calendarDays[weekIndex * 7 + dayIndex];
                          final isCurrentMonth = _isDateInCurrentMonth(dayDate);
                          final isToday = _isToday(dayDate);
                          final isCompleted = _isHabitCompleted(
                            dayDate,
                            currentHabit,
                          );
                          final isFutureDate = dayDate.isAfter(_today);

                          return Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCompleted && isCurrentMonth
                                    ? currentHabit.color
                                    : isToday
                                    ? Colors.grey.withAlpha(30)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: isCurrentMonth && !isFutureDate
                                    ? () => _toggleHabitCompletion(dayDate)
                                    : null,
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                child: Center(
                                  child: Text(
                                    dayDate.day.toString(),
                                    style: TextStyle(
                                      color: isCompleted && isCurrentMonth
                                          ? (currentHabit.color
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors
                                                      .black // Dark text on light background
                                                : Colors
                                                      .white) // White text on dark background
                                          : isCurrentMonth
                                          ? (isFutureDate
                                                ? AppColors.secondaryTextColor
                                                      .withAlpha(128)
                                                : AppColors.primaryTextColor)
                                          : AppColors.secondaryTextColor
                                                .withAlpha(77),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Today button
                Row(
                  children: [
                    TextButton(
                      onPressed: _jumpToToday,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.withAlpha(25),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
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
  }
}
