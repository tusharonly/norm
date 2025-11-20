import 'package:flutter/material.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/models/reminder_model.dart';
import 'package:norm/src/services/notification_service.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  final habits = AppDatabase.getHabits();
  final _notificationService = NotificationService();

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

    // Update UI immediately
    notifyListeners();

    // Schedule notifications for reminders in the background
    if (reminders.isNotEmpty) {
      await _notificationService.scheduleHabitReminders(habits[id]!);
    }
  }

  Future<void> editHabit(HabitModel habit) async {
    habits[habit.id] = habit;
    AppDatabase.saveHabit(habits[habit.id]!);

    // Update UI immediately
    notifyListeners();

    // Reschedule notifications in the background
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
  }

  Future<void> deleteHabit(String id) async {
    // Cancel all notifications for this habit
    await _notificationService.cancelHabitReminders(id);

    habits.remove(id);
    AppDatabase.deleteHabit(id);
    notifyListeners();
  }
}
