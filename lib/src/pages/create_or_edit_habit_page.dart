import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/color_picker_row.dart';
import 'package:norm/src/widgets/input_section.dart';
import 'package:norm/src/widgets/text_field.dart';
import 'package:provider/provider.dart';

class CreateOrEditHabitPage extends StatefulWidget {
  const CreateOrEditHabitPage({super.key, this.habit});

  final HabitModel? habit;

  @override
  State<CreateOrEditHabitPage> createState() => _CreateOrEditHabitPageState();
}

class _CreateOrEditHabitPageState extends State<CreateOrEditHabitPage> {
  Color selectedColor = AppColors.habitColors.first;

  String habitName = '';
  String habitDescription = '';

  void createHabit() {
    context.read<HabitsProvider>().createHabit(
      name: habitName,
      color: selectedColor,
      description: habitDescription,
    );
    AppRouter.pop();
  }

  void editHabit() {
    context.read<HabitsProvider>().editHabit(
      widget.habit!.copyWith(
        name: habitName,
        color: selectedColor,
      ),
    );
    AppRouter.pop();
  }

  void deleteHabit() {
    context.read<HabitsProvider>().deleteHabit(widget.habit!.id);
    AppRouter.pop();
  }

  void showDeleteConfirmationDialog() => showDialog(
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
          'Are you sure you want to delete "${widget.habit!.name}"? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.secondaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: AppRouter.pop,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              AppRouter.pop(true);
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

  @override
  void initState() {
    if (widget.habit != null) {
      habitName = widget.habit!.name;
      habitDescription = widget.habit!.description;
      selectedColor = widget.habit!.color;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? 'Edit Habit' : 'New Habit'),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: Colors.white),
          onPressed: AppRouter.pop,
        ),
        actions: [
          if (widget.habit != null)
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerColor,
              ),
              icon: Icon(LucideIcons.trash, color: Colors.white, size: 20),
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
            onPressed: habitName.isNotEmpty
                ? (widget.habit != null ? editHabit : createHabit)
                : null,
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
              InputSection(
                title: "Name",
                child: AppTextField(
                  hint: 'eg. Running',
                  onChanged: (name) => setState(() => habitName = name),
                ),
              ),
              InputSection(
                title: "Description",
                child: AppTextField(
                  hint: 'eg. Run 5km daily',
                  onChanged: (description) =>
                      setState(() => habitDescription = description),
                ),
              ),
              InputSection(
                title: "Color",
                child: Card(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
