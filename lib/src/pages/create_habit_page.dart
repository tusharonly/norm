import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:norm/src/core/haptic.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/widgets/color_picker_row.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  Color selectedColor = Colors.lightBlueAccent;
  String selectedEmoji = '🧘🏻';

  @override
  Widget build(BuildContext context) {
    return KeyboardEmojiPickerWrapper(
      child: GestureDetector(
        onTap: () {
          if (Platform.isIOS) {
            KeyboardEmojiPicker().closeEmojiKeyboard();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Create'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton.filledTonal(
                icon: Icon(Icons.close_rounded),
                onPressed: () {
                  AppHaptic.buttonPressed();
                  AppRouter.pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 16,
                        children: [
                          SizedBox(height: 14),
                          GestureDetector(
                            onTap: () async {
                              AppHaptic.buttonPressed();
                              final hasEmojiKeyboard =
                                  await KeyboardEmojiPicker()
                                      .checkHasEmojiKeyboard();

                              if (hasEmojiKeyboard) {
                                final emoji = await KeyboardEmojiPicker()
                                    .pickEmoji();
                                if (emoji == null) return;
                                setState(() => selectedEmoji = emoji);
                              } else {
                                // Use another way to pick an emoji or show a dialog asking the user to
                                // enable the emoji keyboard.
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: selectedColor.withAlpha(40),
                              radius: 60,
                              child: Text(
                                selectedEmoji,
                                style: TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                          ColorPickerRow(
                            onColorSelected: (color) {
                              setState(() => selectedColor = color);
                            },
                            selectedColor: selectedColor,
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
