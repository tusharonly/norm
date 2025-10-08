import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/core/extensions.dart';
import 'package:norm/src/core/haptic.dart';
import 'package:norm/src/pages/create_habit_page.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:provider/provider.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits'),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              AppHaptic.buttonPressed();
            },
            icon: Icon(LucideIcons.settings),
          ),
          SizedBox(width: 4),
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              AppHaptic.buttonPressed();
              AppRouter.push(CreateHabitPage(), fullscreenDialog: true);
            },
            icon: Icon(LucideIcons.plus, color: Colors.black),
          ),
        ],
      ),

      body: Consumer<HabitsProvider>(
        builder: (context, hp, child) {
          if (hp.habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: kToolbarHeight + 16),
                child: Text(
                  "Tap + to add your first habit.",
                  style: TextStyle(color: AppColors.secondaryTextColor),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 16.0),
            child: Column(
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: List.generate(
                              7,
                              (index) {
                                final isToday = index == 0;
                                final date = DateTime.now().subtract(
                                  Duration(days: index),
                                );
                                return Container(
                                  width: constraints.maxWidth / 7,
                                  color: AppColors.scaffoldBackgroundColor,
                                  child: Column(
                                    spacing: 2,
                                    children: [
                                      Text(
                                        DateFormat.d().format(date),
                                        style: TextStyle(
                                          color: isToday
                                              ? AppColors.primaryColor
                                              : AppColors.secondaryTextColor,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.E().format(date),
                                        style: TextStyle(
                                          color: isToday
                                              ? AppColors.primaryColor
                                              : AppColors.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).reversed.toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(hp.habits.length, (index) {
                        final habit = hp.habits.values.toList()[index];

                        return Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                habit.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    children: List.generate(
                                      7,
                                      (index) {
                                        final date = DateTime.now().subtract(
                                          Duration(days: 6 - index),
                                        );
                                        final isDone = habit.history.contains(
                                          date.onlydate,
                                        );

                                        return InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: () {
                                            AppHaptic.successPressed();
                                            hp.toggleHabitDone(
                                              id: habit.id,
                                              date: date,
                                            );
                                          },
                                          child: SizedBox(
                                            width: constraints.maxWidth / 7,
                                            height: 35,
                                            child: Center(
                                              child: AnimatedContainer(
                                                duration: Duration(
                                                  milliseconds: 500,
                                                ),
                                                curve: Curves.elasticOut,
                                                width: isDone ? 20 : 10,
                                                height: isDone ? 20 : 10,
                                                decoration: BoxDecoration(
                                                  color: habit.color.withAlpha(
                                                    isDone ? 255 : 255 ~/ 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isDone ? 4 : 10,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
