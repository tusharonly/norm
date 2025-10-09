import 'package:flutter/material.dart';
import 'package:norm/src/utils/haptic.dart';

class FAB extends StatelessWidget {
  const FAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        AppHaptic.buttonPressed();
        onPressed?.call();
      },
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}
