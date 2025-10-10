import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/pages/create_habit_page.dart';
import 'package:norm/src/pages/edit_habit_page.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:norm/src/utils/haptic.dart';
import 'package:provider/provider.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits'),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardBackgroundColor,
            ),
            onPressed: () {
              AppHaptic.buttonPressed();
            },
            iconSize: 20,
            icon: Icon(LucideIcons.settings),
          ),
          SizedBox(width: 4),
          IconButton(
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
          SizedBox(width: 8),
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
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              bottom: 16.0,
              right: 16.0,
            ),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
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
                Column(
                  children: List.generate(
                    hp.habits.length,
                    (index) {
                      final habit = hp.habits.values.toList()[index];

                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () {
                                AppHaptic.buttonPressed();
                                AppRouter.push(
                                  EditHabitPage(habit: habit),
                                  fullscreenDialog: true,
                                );
                              },
                              child: Text(
                                habit.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  color: AppColors.primaryTextColor,
                                ),
                                maxLines: 1,
                              ),
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
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                              width: isDone ? 18 : 8,
                                              height: isDone ? 19 : 8,
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
                    },
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
