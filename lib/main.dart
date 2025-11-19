import 'package:flutter/material.dart';
import 'package:norm/src/app.dart';
import 'package:norm/src/core/database.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:norm/src/services/notification_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitsProvider(),
      child: NormApp(),
    ),
  );
}
