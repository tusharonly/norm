import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static push(
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    navigatorKey.currentState?.push(
      route(page, fullscreenDialog: fullscreenDialog),
    );
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  static route(
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      );
    }
    return MaterialPageRoute(
      builder: (context) => page,
      fullscreenDialog: fullscreenDialog,
    );
  }
}
