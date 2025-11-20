import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/models/reminder_model.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/add_reminder_sheet.dart';
import 'package:norm/src/widgets/color_picker_row.dart';
import 'package:norm/src/widgets/input_section.dart';
import 'package:norm/src/widgets/reminder_card.dart';
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
  HabitInterval selectedInterval = HabitInterval.daily;
  int targetFrequency = 1;
  List<ReminderModel> reminders = [];

  late TextEditingController nameController;
  late TextEditingController descriptionController;

  void createHabit() {
    context.read<HabitsProvider>().createHabit(
      name: habitName,
      color: selectedColor,
      description: habitDescription,
      interval: selectedInterval,
      targetFrequency: targetFrequency,
      reminders: reminders,
    );
    AppRouter.pop();
  }

  void editHabit() {
    context.read<HabitsProvider>().editHabit(
      widget.habit!.copyWith(
        name: habitName,
        description: habitDescription,
        color: selectedColor,
        interval: selectedInterval,
        targetFrequency: targetFrequency,
        reminders: reminders,
      ),
    );
    AppRouter.pop();
  }

  void deleteHabit() {
    context.read<HabitsProvider>().deleteHabit(widget.habit!.id);
    AppRouter.pop(true); // Return true to indicate deletion
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
      selectedInterval = widget.habit!.interval;
      targetFrequency = widget.habit!.targetFrequency;
      reminders = List.from(widget.habit!.reminders);
    }

    nameController = TextEditingController(text: habitName);
    descriptionController = TextEditingController(text: habitDescription);

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    controller: nameController,
                    onChanged: (name) => setState(() => habitName = name),
                  ),
                ),
                InputSection(
                  title: "Description",
                  child: AppTextField(
                    hint: 'eg. Run 5km daily',
                    controller: descriptionController,
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
                InputSection(
                  title: "Interval",
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildIntervalOption(HabitInterval.daily, 'Daily'),
                            _buildIntervalOption(
                              HabitInterval.weekly,
                              'Weekly',
                            ),
                            _buildIntervalOption(
                              HabitInterval.monthly,
                              'Monthly',
                            ),
                          ],
                        ),
                      ),
                      if (selectedInterval != HabitInterval.daily)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ).copyWith(left: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$targetFrequency times per ${selectedInterval == HabitInterval.weekly ? 'week' : 'month'}',
                                  style: TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildFrequencyButton(
                                      icon: LucideIcons.minus,
                                      onTap: targetFrequency > 1
                                          ? () => setState(
                                              () => targetFrequency--,
                                            )
                                          : null,
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 40,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$targetFrequency',
                                        style: TextStyle(
                                          color: AppColors.primaryTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildFrequencyButton(
                                      icon: LucideIcons.plus,
                                      onTap: () {
                                        if (selectedInterval ==
                                                HabitInterval.weekly &&
                                            targetFrequency >= 6) {
                                          return;
                                        }
                                        if (selectedInterval ==
                                                HabitInterval.monthly &&
                                            targetFrequency >= 25) {
                                          return;
                                        }
                                        setState(() => targetFrequency++);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                InputSection(
                  title: "Reminders",
                  child: Column(
                    spacing: 8,
                    children: [
                      if (reminders.isNotEmpty)
                        ...reminders.map(
                          (reminder) => ReminderCard(
                            reminder: reminder,
                            onDelete: () {
                              setState(() {
                                reminders.remove(reminder);
                              });
                            },
                          ),
                        ),
                      GestureDetector(
                        onTap: () async {
                          final reminder =
                              await showModalBottomSheet<ReminderModel>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (context) => const AddReminderSheet(),
                              );
                          if (reminder != null) {
                            setState(() {
                              reminders.add(reminder);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.plus,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Reminder',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalOption(HabitInterval interval, String label) {
    final isSelected = selectedInterval == interval;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedInterval = interval;
            if (selectedInterval == HabitInterval.daily) {
              targetFrequency = 1;
            } else if (selectedInterval == HabitInterval.weekly) {
              targetFrequency = 3;
            } else {
              targetFrequency = 10;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.secondaryTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: onTap != null
                ? AppColors.primaryTextColor
                : AppColors.secondaryTextColor.withAlpha(100),
          ),
        ),
      ),
    );
  }
}
