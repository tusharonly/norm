import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:norm/src/app.dart';
import 'package:norm/src/core/haptic.dart';
import 'package:norm/src/providers/habits_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await AppHaptic.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitsProvider(),
      child: NormApp(),
    ),
  );
}
