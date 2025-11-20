import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/reminder_model.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/utils/toast.dart';
import 'package:uuid/uuid.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(
    DateTime.now().add(Duration(minutes: 1)),
  );
  Set<int> selectedDays = {1, 2, 3, 4, 5, 6, 7};

  final List<String> dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  void _saveReminder() {
    if (selectedDays.isEmpty) {
      Toast.error(context, 'Please select at least one day');
      return;
    }

    final reminder = ReminderModel(
      id: const Uuid().v4(),
      hour: selectedTime.hour,
      minute: selectedTime.minute,
      selectedDays: selectedDays.toList()..sort(),
    );

    Navigator.of(context).pop(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20).copyWith(top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Reminder',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Day Selection
            Text(
              'Days',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,

              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = selectedDays.contains(day);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleDay(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          dayNames[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppColors.secondaryTextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            // Time Selection
            Text(
              'Time',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime.format(context),
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedDays.isEmpty ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
