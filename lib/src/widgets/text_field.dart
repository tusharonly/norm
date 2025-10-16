import 'package:flutter/material.dart';
import 'package:norm/src/theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.textCapitalization,
  });

  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextCapitalization? textCapitalization;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(60),
      borderSide: BorderSide.none,
    );

    return TextField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hint: hint != null
            ? Text(
                hint!,
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        border: inputBorder,
        errorBorder: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedErrorBorder: inputBorder,
        filled: true,
        fillColor: AppColors.cardBackgroundColor,
      ),
      textCapitalization: textCapitalization ?? TextCapitalization.sentences,
    );
  }
}
