import 'package:flutter/material.dart';
import 'package:norm/src/core/haptic.dart';
import 'package:norm/src/theme.dart';

class ColorPickerRow extends StatefulWidget {
  const ColorPickerRow({
    super.key,
    required this.onColorSelected,
    required this.selectedColor,
  });

  final ValueChanged<Color> onColorSelected;
  final Color selectedColor;

  @override
  State<ColorPickerRow> createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends State<ColorPickerRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        spacing: 16,
        children: List.generate(
          2,
          (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var color
                    in index == 0
                        ? AppColors.habitColors.sublist(0, 4)
                        : AppColors.habitColors.sublist(4))
                  GestureDetector(
                    onTap: () {
                      AppHaptic.buttonPressed();
                      widget.onColorSelected(color);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: widget.selectedColor == color
                          ? Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                        60,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
