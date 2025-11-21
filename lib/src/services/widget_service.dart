import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:norm/src/models/habit_model.dart';

class WidgetService {
  static const String _androidWidgetName = 'HabitWidgetProvider';

  static Future<void> initialize() async {
    try {
      debugPrint('WidgetService: Initialized');
    } catch (e) {
      debugPrint('Error initializing widget service: $e');
    }
  }

  static Future<void> updateWidget(Map<String, HabitModel> habits) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('WidgetService: UPDATE TRIGGERED');
      debugPrint('WidgetService: Updating widget with ${habits.length} habits');
      debugPrint('WidgetService: Timestamp: ${DateTime.now().millisecondsSinceEpoch}');

      final widgetData = _prepareWidgetData(habits);
      debugPrint(
        'WidgetService: Data size: ${widgetData.length} bytes',
      );

      await HomeWidget.saveWidgetData<String>('habits_data', widgetData);
      debugPrint('WidgetService: Data saved to shared preferences');

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );

      debugPrint('WidgetService: Widget update completed');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      debugPrint('WidgetService ERROR: $e');
      debugPrint('WidgetService ERROR Stack: ${StackTrace.current}');
    }
  }

  static String _prepareWidgetData(Map<String, HabitModel> habits) {
    final habitsList = habits.values.toList();

    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    final widgetHabits = habitsList.map((habit) {
      final completions = dates.map((date) {
        return habit.isCompletedForDate(date);
      }).toList();

      return {
        'id': habit.id,
        'name': habit.name,
        'color': habit.color.value,
        'completions': completions,
      };
    }).toList();

    final dayLabels = dates.map((date) {
      return {
        'label': DateFormat.E().format(date)[0],
        'isToday':
            date.day == today.day &&
            date.month == today.month &&
            date.year == today.year,
      };
    }).toList();

    final data = {
      'habits': widgetHabits,
      'days': dayLabels,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    return json.encode(data);
  }
}
