import 'dart:convert';

class ReminderModel {
  final String id;
  final int hour; // 0-23
  final int minute; // 0-59
  final List<int> selectedDays; // 1-7 (Monday-Sunday)

  ReminderModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.selectedDays,
  });

  String get timeString {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String get daysString {
    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.isEmpty) return 'No days selected';

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = [...selectedDays]..sort();
    return sortedDays.map((day) => dayNames[day - 1]).join(', ');
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hour': hour,
      'minute': minute,
      'selectedDays': selectedDays,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      selectedDays: List<int>.from(map['selectedDays'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReminderModel.fromJson(String source) =>
      ReminderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ReminderModel copyWith({
    String? id,
    int? hour,
    int? minute,
    List<int>? selectedDays,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}
