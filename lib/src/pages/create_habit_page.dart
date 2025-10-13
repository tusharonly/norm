import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/color_picker_row.dart';
import 'package:provider/provider.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  Color selectedColor =
      AppColors.habitColors[Random(
        DateTime.now().millisecondsSinceEpoch,
      ).nextInt(AppColors.habitColors.length)];
  String habitName = '';

  void createHabit() {
    context.read<HabitsProvider>().createHabit(
      name: habitName,
      color: selectedColor,
    );
    AppRouter.pop();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(60),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit'),
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
              backgroundColor: AppColors.successColor,
            ),
            icon: Icon(
              LucideIcons.check,
              color: habitName.isNotEmpty ? Colors.white : Colors.grey,
            ),
            onPressed: habitName.isNotEmpty ? createHabit : null,
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
                      "Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextField(
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (value) {
                      setState(() => habitName = value);
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
