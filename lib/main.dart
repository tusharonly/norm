import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:norm/src/app.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/services/notification_service.dart';
import 'package:norm/src/services/widget_service.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.init();

  final notificationService = NotificationService();
  await notificationService.initialize();

  await WidgetService.initialize();

  HomeWidget.registerInteractivityCallback(backgroundCallback);

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = HabitsProvider();
        WidgetService.updateWidget(provider.habits);
        return provider;
      },
      child: NormApp(),
    ),
  );
}

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  debugPrint('Widget background callback: $uri');

  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init();

  final habitId = uri.queryParameters['habitId'];
  final dayIndexStr = uri.queryParameters['dayIndex'];

  if (habitId != null && dayIndexStr != null) {
    final dayIndex = int.tryParse(dayIndexStr);
    if (dayIndex != null) {
      debugPrint('Toggling habit $habitId, day $dayIndex');

      final habits = AppDatabase.getHabits();
      final habit = habits[habitId];

      if (habit != null) {
        final today = DateTime.now();
        final targetDate = today.subtract(Duration(days: 6 - dayIndex));

        final completions = {...habit.completions};
        if (habit.isCompletedForDate(targetDate)) {
          completions.remove(targetDate.onlydate);
          debugPrint('Unmarked habit for ${targetDate.onlydate}');
        } else {
          completions[targetDate.onlydate] = CompletionModel(
            date: targetDate.onlydate,
            numberOfCompletions: 1,
          );
          debugPrint('Marked habit as complete for ${targetDate.onlydate}');
        }

        final updatedHabit = habit.copyWith(completions: completions);
        habits[habitId] = updatedHabit;
        AppDatabase.saveHabit(updatedHabit);

        await WidgetService.updateWidget(habits);
        debugPrint('Widget updated with toggled habit');
      }
    }
  }
}
