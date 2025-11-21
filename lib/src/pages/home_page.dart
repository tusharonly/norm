import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/pages/create_or_edit_habit_page.dart';
import 'package:norm/src/pages/habit_details_page.dart';
import 'package:norm/src/pages/settings_page.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('HomePage: App resumed - reloading habits');
      try {
        final provider = context.read<HabitsProvider>();
        provider.reloadHabits();
        debugPrint('HomePage: Habits reloaded successfully');
      } catch (e) {
        debugPrint('HomePage: Error reloading habits: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits'),
        leading: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.cardBackgroundColor,
          ),
          onPressed: () {
            AppRouter.push(SettingsPage());
          },
          iconSize: 20,
          icon: Icon(LucideIcons.settings),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              AppRouter.push(CreateOrEditHabitPage(), fullscreenDialog: true);
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
                                  alignment: Alignment.center,
                                  width: constraints.maxWidth / 7,
                                  color: AppColors.scaffoldBackgroundColor,
                                  child: Text(
                                    DateFormat.E().format(date)[0],
                                    style: TextStyle(
                                      color: isToday
                                          ? AppColors.primaryColor
                                          : AppColors.secondaryTextColor
                                                .withValues(alpha: 0.4),
                                      fontWeight: FontWeight.bold,
                                    ),
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
                SizedBox(height: 16),
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
                                AppRouter.push(
                                  HabitDetailsPage(habit: habit),
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
                                      final isDone = habit.isCompletedForDate(
                                        date,
                                      );

                                      return InkWell(
                                        splashFactory: NoSplash.splashFactory,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        onTap: () {
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
                                              width: isDone ? 18 : 8,
                                              height: isDone ? 18 : 8,
                                              decoration: BoxDecoration(
                                                color: habit.color.withValues(
                                                  alpha: isDone ? 1 : 0.4,
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
