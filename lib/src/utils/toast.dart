import 'package:flutter/material.dart';
import 'package:norm/src/theme.dart';

class Toast {
  static void success(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle,
    );
  }

  static void error(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: AppColors.dangerColor,
      icon: Icons.error,
    );
  }

  static void info(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void warning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  static void loading(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: AppColors.cardBackgroundColor,
      icon: null,
      duration: const Duration(seconds: 1),
      showLoading: true,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool showLoading = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryTextColor,
                  ),
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            if (icon != null || showLoading) const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 6,
      ),
    );
  }
}
