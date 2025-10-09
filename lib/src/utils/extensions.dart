import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get onlydate => DateFormat('dd-MM-yyyy').format(this);
}
