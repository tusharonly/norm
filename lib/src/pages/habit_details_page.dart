import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/pages/create_or_edit_habit_page.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/activity_calender.dart';

class HabitDetailsPage extends StatefulWidget {
  const HabitDetailsPage({super.key, required this.habit});

  final HabitModel habit;

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  @override
  Widget build(BuildContext context) {
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
                backgroundColor: AppColors.primaryColor,
              ),
              icon: Icon(
                LucideIcons.pencilLine,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                AppRouter.pop();
                AppRouter.push(
                  CreateOrEditHabitPage(habit: widget.habit),
                  fullscreenDialog: true,
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                // Description section (only show if description exists)
                if (widget.habit.description.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.habit.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ActivityCalender(habit: widget.habit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
