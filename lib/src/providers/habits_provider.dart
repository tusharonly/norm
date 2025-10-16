import 'package:flutter/material.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  final habits = AppDatabase.getHabits();

  Future<void> createHabit({
    required String name,
    required String description,
    required Color color,
  }) async {
    final id = Uuid().v4();
    habits[id] = HabitModel(
      id: id,
      name: name,
      description: description,
      color: color,
      order: habits.length,
    );
    AppDatabase.saveHabit(habits[id]!);
    notifyListeners();
  }

  Future<void> editHabit(HabitModel habit) async {
    habits[habit.id] = habit;
    AppDatabase.saveHabit(habits[habit.id]!);
    notifyListeners();
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
    habits.remove(id);
    AppDatabase.deleteHabit(id);
    notifyListeners();
  }
}
