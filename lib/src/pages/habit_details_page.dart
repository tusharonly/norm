import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/pages/create_or_edit_habit_page.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:norm/src/widgets/activity_calender.dart';
import 'package:norm/src/widgets/streaks_card.dart';

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
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  AppRouter.route(
                    CreateOrEditHabitPage(habit: widget.habit),
                    fullscreenDialog: true,
                  ),
                );
                if (result == true && context.mounted) {
                  AppRouter.pop();
                }
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
                if (widget.habit.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Description: ${widget.habit.description}",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Activity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    ActivityCalender(habit: widget.habit),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Streaks",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    StreaksCard(habit: widget.habit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
