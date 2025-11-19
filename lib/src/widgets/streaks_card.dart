import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/theme.dart';
import 'package:provider/provider.dart';

class StreaksCard extends StatelessWidget {
  const StreaksCard({super.key, required this.habit});

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, child) {
        final currentHabit = provider.habits[habit.id] ?? habit;
        final streak = currentHabit.currentStreak;
        final bestStreak = currentHabit.longestStreak;
        final interval = currentHabit.interval;
        String unit = 'day';
        if (interval == HabitInterval.weekly) unit = 'week';
        if (interval == HabitInterval.monthly) unit = 'month';

        String streakUnit = unit + (streak != 1 ? 's' : '');
        String bestStreakUnit = unit + (bestStreak != 1 ? 's' : '');

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: AppColors.cardBackgroundColor,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.flame,
                            color: currentHabit.color,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Current Streak",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        "$streak $streakUnit",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withAlpha(50),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.trophy,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Best Streak",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "$bestStreak $bestStreakUnit",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
