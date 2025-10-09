import 'package:flutter/material.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  final habits = AppDatabase.getHabits();

  Future<void> createHabit({
    required String name,
    required Color color,
  }) async {
    final id = Uuid().v4();
    habits[id] = HabitModel(id: id, name: name, color: color);
    AppDatabase.saveHabit(habits[id]!);
    notifyListeners();
  }

  Future<void> toggleHabitDone({
    required String id,
    required DateTime date,
  }) async {
    if (habits[id]!.history.contains(date.onlydate)) {
      habits[id] = habits[id]!.copyWith(
        history: habits[id]!.history
            .where((element) => element != date.onlydate)
            .toList(),
      );
    } else {
      habits[id] = habits[id]!.copyWith(
        history: [...habits[id]!.history, date.onlydate],
      );
    }
    AppDatabase.saveHabit(habits[id]!);
    notifyListeners();
  }
}
