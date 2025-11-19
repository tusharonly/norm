import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:norm/src/utils/extensions.dart';

enum HabitInterval { daily, weekly, monthly }

class HabitModel {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int order;
  final int numberOfCompletionsPerDay;
  final Map<String, CompletionModel> completions;
  final HabitInterval interval;
  final int targetFrequency;

  HabitModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.color,
    required this.order,
    this.numberOfCompletionsPerDay = 1,
    this.completions = const {},
    this.interval = HabitInterval.daily,
    this.targetFrequency = 1,
  });

  bool isCompletedForDate(DateTime date) {
    if (completions[date.onlydate] == null) return false;
    return completions[date.onlydate]!.numberOfCompletions >=
        numberOfCompletionsPerDay;
  }

  int get currentStreak {
    final sortedDates = completions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    if (sortedDates.isEmpty) return 0;

    int streak = 0;
    DateTime now = DateTime.now();

    if (interval == HabitInterval.daily) {
      // Check if today is completed
      bool todayCompleted = isCompletedForDate(now);
      DateTime checkDate = now;

      if (!todayCompleted) {
        // If today is not completed, check yesterday to see if streak is still active
        checkDate = now.subtract(Duration(days: 1));
        if (!isCompletedForDate(checkDate)) {
          return 0;
        }
      }

      // Count backwards
      while (true) {
        if (isCompletedForDate(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(Duration(days: 1));
        } else {
          break;
        }
      }
    } else if (interval == HabitInterval.weekly) {
      // Weekly logic
      // Check current week
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      int currentWeekCount = _countCompletionsInPeriod(
        currentWeekStart,
        currentWeekStart.add(Duration(days: 6)),
      );

      DateTime checkWeekStart = currentWeekStart;

      // If current week is met, we count it.
      // If not, we don't count it, but we check if we should continue checking previous weeks.
      // Standard streak logic: if current period is in progress (not met), streak is not broken,
      // but current period doesn't add to streak yet.

      if (currentWeekCount >= targetFrequency) {
        streak++;
      }

      // Move to previous week
      checkWeekStart = checkWeekStart.subtract(Duration(days: 7));

      while (true) {
        int count = _countCompletionsInPeriod(
          checkWeekStart,
          checkWeekStart.add(Duration(days: 6)),
        );
        if (count >= targetFrequency) {
          streak++;
          checkWeekStart = checkWeekStart.subtract(Duration(days: 7));
        } else {
          break;
        }
      }
    } else if (interval == HabitInterval.monthly) {
      // Monthly logic
      DateTime currentMonthStart = DateTime(now.year, now.month, 1);
      DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);
      int currentMonthCount = _countCompletionsInPeriod(
        currentMonthStart,
        nextMonthStart.subtract(Duration(days: 1)),
      );

      DateTime checkMonthStart = currentMonthStart;

      if (currentMonthCount >= targetFrequency) {
        streak++;
      }

      // Move to previous month
      checkMonthStart = DateTime(
        checkMonthStart.year,
        checkMonthStart.month - 1,
        1,
      );

      while (true) {
        DateTime checkMonthEnd = DateTime(
          checkMonthStart.year,
          checkMonthStart.month + 1,
          1,
        ).subtract(Duration(days: 1));
        int count = _countCompletionsInPeriod(checkMonthStart, checkMonthEnd);

        if (count >= targetFrequency) {
          streak++;
          checkMonthStart = DateTime(
            checkMonthStart.year,
            checkMonthStart.month - 1,
            1,
          );
        } else {
          break;
        }
      }
    }

    return streak;
  }

  int get longestStreak {
    if (completions.isEmpty) return 0;

    final dateFormat = DateFormat('dd-MM-yyyy');
    final sortedDates =
        completions.keys.map((e) => dateFormat.parse(e)).toList()
          ..sort((a, b) => a.compareTo(b)); // Oldest first

    int maxStreak = 0;
    int currentStreak = 0;

    if (interval == HabitInterval.daily) {
      DateTime? lastDate;
      for (var date in sortedDates) {
        // We know the date is completed because it came from completions keys
        if (lastDate != null && date.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        lastDate = date;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      }
    } else if (interval == HabitInterval.weekly) {
      if (sortedDates.isEmpty) return 0;

      DateTime firstDate = sortedDates.first;
      DateTime lastDate = sortedDates.last;

      // Align to start of week
      DateTime start = firstDate.subtract(
        Duration(days: firstDate.weekday - 1),
      );
      DateTime end = lastDate.add(Duration(days: 7 - lastDate.weekday));

      int currentRun = 0;

      while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
        DateTime weekEnd = start.add(Duration(days: 6));
        int count = _countCompletionsInPeriod(start, weekEnd);

        if (count >= targetFrequency) {
          currentRun++;
        } else {
          currentRun = 0;
        }

        if (currentRun > maxStreak) maxStreak = currentRun;
        start = start.add(Duration(days: 7));
      }
    } else if (interval == HabitInterval.monthly) {
      if (sortedDates.isEmpty) return 0;

      DateTime firstDate = sortedDates.first;
      DateTime lastDate = sortedDates.last;

      DateTime start = DateTime(firstDate.year, firstDate.month, 1);
      DateTime end = DateTime(
        lastDate.year,
        lastDate.month + 1,
        1,
      ).subtract(Duration(days: 1));

      int currentRun = 0;

      while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
        DateTime monthEnd = DateTime(
          start.year,
          start.month + 1,
          1,
        ).subtract(Duration(days: 1));
        int count = _countCompletionsInPeriod(start, monthEnd);

        if (count >= targetFrequency) {
          currentRun++;
        } else {
          currentRun = 0;
        }

        if (currentRun > maxStreak) maxStreak = currentRun;
        start = DateTime(start.year, start.month + 1, 1);
      }
    }

    return maxStreak;
  }

  int _countCompletionsInPeriod(DateTime start, DateTime end) {
    int count = 0;
    // Iterate through days in period
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      DateTime date = start.add(Duration(days: i));
      if (isCompletedForDate(date)) {
        count++;
      }
    }
    return count;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'color': color.toARGB32(),
      'order': order,
      'numberOfCompletionsPerDay': numberOfCompletionsPerDay,
      'completions': completions.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'interval': interval.index,
      'targetFrequency': targetFrequency,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] ?? '',
      color: Color(map['color'] as int),
      order: map['order'] as int,
      numberOfCompletionsPerDay: map['numberOfCompletionsPerDay'] as int,
      completions: Map<String, CompletionModel>.from(
        map['completions']?.map(
          (key, value) => MapEntry(key, CompletionModel.fromMap(value)),
        ),
      ),
      interval: HabitInterval.values[map['interval'] ?? 0],
      targetFrequency: map['targetFrequency'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory HabitModel.fromJson(String source) =>
      HabitModel.fromMap(json.decode(source) as Map<String, dynamic>);

  HabitModel copyWith({
    String? name,
    String? description,
    Color? color,
    int? order,
    List<String>? history,
    int? numberOfCompletionsPerDay,
    Map<String, CompletionModel>? completions,
    HabitInterval? interval,
    int? targetFrequency,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      order: order ?? this.order,
      numberOfCompletionsPerDay:
          numberOfCompletionsPerDay ?? this.numberOfCompletionsPerDay,
      completions: completions ?? this.completions,
      interval: interval ?? this.interval,
      targetFrequency: targetFrequency ?? this.targetFrequency,
    );
  }
}

class CompletionModel {
  final String date;
  final int numberOfCompletions;

  CompletionModel({
    required this.date,
    required this.numberOfCompletions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'numberOfCompletions': numberOfCompletions,
    };
  }

  factory CompletionModel.fromMap(Map<String, dynamic> map) {
    return CompletionModel(
      date: map['date'] as String,
      numberOfCompletions: map['numberOfCompletions'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompletionModel.fromJson(String source) =>
      CompletionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
