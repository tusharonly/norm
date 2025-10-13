import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/activity_calender.dart';
import 'package:norm/src/widgets/color_picker_row.dart';
import 'package:provider/provider.dart';

class EditHabitPage extends StatefulWidget {
  const EditHabitPage({super.key, required this.habit});

  final HabitModel habit;

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  Color selectedColor =
      AppColors.habitColors[Random(
        DateTime.now().millisecondsSinceEpoch,
      ).nextInt(AppColors.habitColors.length)];
  String habitName = '';
  final habitNameController = TextEditingController();

  void editHabit() {
    context.read<HabitsProvider>().editHabit(
      widget.habit.copyWith(
        name: habitName,
        color: selectedColor,
      ),
    );
    AppRouter.pop();
  }

  void deleteHabit() {
    context.read<HabitsProvider>().deleteHabit(widget.habit.id);
    AppRouter.pop();
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Text(
            'Delete Habit',
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.habit.name}"? This action cannot be undone.',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteHabit();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.dangerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    habitNameController.text = widget.habit.name;
    habitName = widget.habit.name;
    selectedColor = widget.habit.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(60),
      borderSide: BorderSide.none,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.habit.name),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(LucideIcons.x, color: Colors.white),
            onPressed: () {
              AppRouter.pop();
            },
          ),

          actions: [
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerColor,
              ),
              icon: Icon(
                LucideIcons.trash2,
                color: Colors.white,
              ),
              onPressed: showDeleteConfirmationDialog,
            ),
            SizedBox(width: 8),
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.successColor,
              ),
              icon: Icon(
                LucideIcons.check,
                color: habitName.isNotEmpty ? Colors.white : Colors.grey,
              ),
              onPressed: habitName.isNotEmpty ? editHabit : null,
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 16,
              children: [
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Activity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ActivityCalender(habit: widget.habit),
                  ],
                ),
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() => habitName = value);
                      },
                      controller: habitNameController,
                      decoration: InputDecoration(
                        hint: Text(
                          'Habit Name',
                          style: TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        border: inputBorder,
                        errorBorder: inputBorder,
                        focusedBorder: inputBorder,
                        enabledBorder: inputBorder,
                        disabledBorder: inputBorder,
                        focusedErrorBorder: inputBorder,
                        filled: true,
                        fillColor: AppColors.cardBackgroundColor,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Color",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ColorPickerRow(
                          onColorSelected: (color) {
                            setState(() => selectedColor = color);
                          },
                          selectedColor: selectedColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
