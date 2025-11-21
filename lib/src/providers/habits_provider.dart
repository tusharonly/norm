import 'package:flutter/material.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/models/reminder_model.dart';
import 'package:norm/src/services/import_export_service.dart';
import 'package:norm/src/services/notification_service.dart';
import 'package:norm/src/services/widget_service.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  Map<String, HabitModel> habits = AppDatabase.getHabits();
  final _notificationService = NotificationService();
  final _importExportService = ImportExportService();

  void reloadHabits() {
    debugPrint('Reloading habits from database...');
    habits = AppDatabase.getHabits();
    debugPrint('Reloaded ${habits.length} habits');
    notifyListeners();
  }

  Future<void> createHabit({
    required String name,
    required String description,
    required Color color,
    HabitInterval interval = HabitInterval.daily,
    int targetFrequency = 1,
    List<ReminderModel> reminders = const [],
  }) async {
    final id = Uuid().v4();
    habits[id] = HabitModel(
      id: id,
      name: name,
      description: description,
      color: color,
      order: habits.length,
      interval: interval,
      targetFrequency: targetFrequency,
      reminders: reminders,
    );
    AppDatabase.saveHabit(habits[id]!);

    notifyListeners();

    await WidgetService.updateWidget(habits);

    if (reminders.isNotEmpty) {
      await _notificationService.scheduleHabitReminders(habits[id]!);
    }
  }

  Future<void> editHabit(HabitModel habit) async {
    habits[habit.id] = habit;
    AppDatabase.saveHabit(habits[habit.id]!);

    notifyListeners();

    await WidgetService.updateWidget(habits);

    await _notificationService.scheduleHabitReminders(habit);
  }

  Future<void> toggleHabitDone({
    required String id,
    required DateTime date,
  }) async {
    final completions = {...habits[id]!.completions};

    if (habits[id]!.isCompletedForDate(date)) {
      completions.remove(date.onlydate);
    } else {
      completions[date.onlydate] = CompletionModel(
        date: date.onlydate,
        numberOfCompletions: 1,
      );
    }

    habits[id] = habits[id]!.copyWith(completions: completions);
    AppDatabase.saveHabit(habits[id]!);
    notifyListeners();

    await WidgetService.updateWidget(habits);
  }

  Future<void> deleteHabit(String id) async {
    await _notificationService.cancelHabitReminders(id);

    habits.remove(id);
    AppDatabase.deleteHabit(id);
    notifyListeners();

    await WidgetService.updateWidget(habits);
  }

  Future<String?> exportHabits() async {
    try {
      final habitsList = habits.values.toList();
      final filePath = await _importExportService.exportHabits(habitsList);
      return filePath;
    } catch (e) {
      debugPrint('Error in exportHabits: $e');
      return null;
    }
  }

  Future<String?> importHabits() async {
    try {
      debugPrint('Starting habit import...');
      final importedHabits = await _importExportService.importHabits();
      debugPrint('Imported ${importedHabits.length} habits');

      for (final habit in importedHabits) {
        habits[habit.id] = habit;
        await AppDatabase.saveHabit(habit);

        if (habit.reminders.isNotEmpty) {
          await _notificationService.scheduleHabitReminders(habit);
        }
      }

      debugPrint('All habits saved to database');

      notifyListeners();

      debugPrint('Updating widget after import...');
      await WidgetService.updateWidget(habits);

      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetService.updateWidget(habits);
      debugPrint('Widget updated after import');

      return null; 
    } catch (e) {
      debugPrint('Error in importHabits: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
