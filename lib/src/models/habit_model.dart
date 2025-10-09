// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'history': history,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      history: List<String>.from(map['history']),
    );
  }

  String toJson() => json.encode(toMap());

  factory HabitModel.fromJson(String source) =>
      HabitModel.fromMap(json.decode(source) as Map<String, dynamic>);

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
}
