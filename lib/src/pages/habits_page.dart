import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/core/haptic.dart';
import 'package:norm/src/pages/create_habit_page.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:provider/provider.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits'),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              AppHaptic.buttonPressed();
            },
            icon: Icon(LucideIcons.settings),
          ),
        ],
      ),

      body: Consumer<HabitsProvider>(
        builder: (context, hp, child) {
          if (hp.habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: kToolbarHeight + 16),
                child: Text(
                  "Tap + to add your first habit.",
                  style: TextStyle(color: AppColors.secondaryTextColor),
                ),
              ),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return Text(hp.habits[index].name);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppHaptic.buttonPressed();
          AppRouter.push(CreateHabitPage(), fullscreenDialog: true);
        },

        child: Icon(LucideIcons.plus, size: 30),
      ),
    );
  }
}
