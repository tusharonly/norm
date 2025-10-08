import 'package:flutter/material.dart';
import 'package:norm/src/core/haptic.dart';

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
  final List<Color> colors = [
    Colors.redAccent,
    Colors.deepOrangeAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.lightGreenAccent,
    Colors.cyanAccent,
    Colors.lightBlueAccent,
    Colors.purpleAccent,
    Colors.indigoAccent,
    Colors.pinkAccent,
    Colors.deepPurpleAccent,
  ];

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
                    in index == 0 ? colors.sublist(0, 6) : colors.sublist(6))
                  GestureDetector(
                    onTap: () {
                      AppHaptic.buttonPressed();
                      widget.onColorSelected(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: widget.selectedColor == color
                          ? Center(
                              child: Container(
                                width: 16,
                                height: 16,
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
