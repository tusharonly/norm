import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:norm/src/utils/extensions.dart';

class HabitModel {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int order;
  final int numberOfCompletionsPerDay;
  final Map<String, CompletionModel> completions;

  HabitModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.color,
    required this.order,
    this.numberOfCompletionsPerDay = 1,
    this.completions = const {},
  });

  bool isCompletedForDate(DateTime date) {
    if (completions[date.onlydate] == null) return false;
    return completions[date.onlydate]!.numberOfCompletions >=
        numberOfCompletionsPerDay;
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
