import 'package:hive_flutter/hive_flutter.dart';
import 'package:norm/src/models/habit_model.dart';

class AppDatabase {
  static Box? _habitsBox;
  static Box get habitsBox => _habitsBox!;

  static Future<void> init() async {
    await Hive.initFlutter();
    _habitsBox = await Hive.openBox('habits');
  }

  static Future<void> saveHabit(HabitModel habit) =>
      habitsBox.put(habit.id, habit.toJson());

  static Map<String, HabitModel> getHabits() {
    final habits = <String, HabitModel>{};
    for (final h in habitsBox.values) {
      final habit = HabitModel.fromJson(h);
      habits[habit.id] = habit;
    }
    return habits;
  }

  static Future<void> deleteHabit(String id) => habitsBox.delete(id);
}
