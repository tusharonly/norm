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

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize widget service
  await WidgetService.initialize();

  // Register background callback for widget interactions
  HomeWidget.registerInteractivityCallback(backgroundCallback);

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = HabitsProvider();
        // Update widget with initial data
        WidgetService.updateWidget(provider.habits);
        return provider;
      },
      child: NormApp(),
    ),
  );
}

/// Background callback to handle widget interactions
@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  debugPrint('Widget background callback: $uri');

  // Initialize database for background operations
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init();

  // Parse the URI to get habitId and dayIndex
  final habitId = uri.queryParameters['habitId'];
  final dayIndexStr = uri.queryParameters['dayIndex'];

  if (habitId != null && dayIndexStr != null) {
    final dayIndex = int.tryParse(dayIndexStr);
    if (dayIndex != null) {
      debugPrint('Toggling habit $habitId, day $dayIndex');

      // Load habits from database
      final habits = AppDatabase.getHabits();
      final habit = habits[habitId];

      if (habit != null) {
        // Calculate the date for the day index (0 = 6 days ago, 6 = today)
        final today = DateTime.now();
        final targetDate = today.subtract(Duration(days: 6 - dayIndex));

        // Toggle completion
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

        // Save updated habit
        final updatedHabit = habit.copyWith(completions: completions);
        habits[habitId] = updatedHabit;
        AppDatabase.saveHabit(updatedHabit);

        // Update widget with new data
        await WidgetService.updateWidget(habits);
        debugPrint('Widget updated with toggled habit');
      }
    }
  }
}
