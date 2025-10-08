import 'package:flutter/material.dart';
import 'package:norm/src/models/habit_model.dart';

class HabitsProvider extends ChangeNotifier {
  final habits = <HabitModel>[];
}
