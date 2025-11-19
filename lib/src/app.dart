import 'package:flutter/material.dart';
import 'package:norm/src/pages/home_page.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';

class NormApp extends StatelessWidget {
  const NormApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontFamily = 'Figtree';
    final theme = ThemeData(
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorSchemeSeed: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextColor,
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.cardBackgroundColor,
        hourMinuteTextColor: AppColors.primaryTextColor,
        dayPeriodTextColor: AppColors.primaryTextColor,
        dialHandColor: AppColors.primaryColor,
        dayPeriodColor: AppColors.primaryColor,
        dialBackgroundColor: AppColors.cardBackgroundColor,
        hourMinuteColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryColor
              : AppColors.cardBackgroundColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
    return MaterialApp(
      home: const HomePage(),
      theme: theme,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
    );
  }
}
