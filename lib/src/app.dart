import 'package:flutter/material.dart';
import 'package:norm/src/pages/habits_page.dart';
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
    );
    return MaterialApp(
      home: const HabitsPage(),
      theme: theme,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
    );
  }
}
