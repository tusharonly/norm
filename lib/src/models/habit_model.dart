// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final Color color;
  final List<String> history;

  HabitModel({
    required this.id,
    required this.name,
    required this.color,
    this.history = const [],
  });

  HabitModel copyWith({
    String? name,
    Color? color,
    List<String>? history,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      history: history ?? this.history,
    );
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, name: $name, color: $color, history: $history)';
  }
}
