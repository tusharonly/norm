import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:norm/src/models/habit_model.dart';

class ImportExportService {
  Future<String?> exportHabits(List<HabitModel> habits) async {
    try {
      final habitsJson = habits.map((h) => h.toMap()).toList();
      final jsonString = JsonEncoder.withIndent('  ').convert(habitsJson);

      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final filename = 'norm_habits_export_$timestamp.json';

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save export',
      );

      if (selectedDirectory == null) {
        return null;
      }

      final filePath = '$selectedDirectory/$filename';
      final file = File(filePath);

      await file.writeAsString(jsonString);

      debugPrint('Habits exported successfully to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      debugPrint('Error exporting habits: $e');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  Future<List<HabitModel>> importHabits() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select habits export file',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Invalid file path');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final jsonString = await file.readAsString();

      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is! List) {
        throw Exception('Invalid file format: Expected a list of habits');
      }

      final habits = <HabitModel>[];
      for (var i = 0; i < jsonData.length; i++) {
        try {
          final habitMap = jsonData[i] as Map<String, dynamic>;
          final habit = HabitModel.fromMap(habitMap);
          habits.add(habit);
        } catch (e) {
          throw Exception('Invalid habit data at index $i: $e');
        }
      }

      if (habits.isEmpty) {
        throw Exception('No valid habits found in file');
      }

      debugPrint('Successfully imported ${habits.length} habits');
      return habits;
    } on FormatException catch (e) {
      debugPrint('JSON parsing error: $e');
      throw Exception(
        'Invalid JSON format: File is corrupted or not a valid export',
      );
    } catch (e) {
      debugPrint('Error importing habits: $e');
      rethrow;
    }
  }
}
