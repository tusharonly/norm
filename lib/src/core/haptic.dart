import 'package:haptic_feedback/haptic_feedback.dart';

class AppHaptic {
  static bool _canVibrate = false;

  static init() async {
    _canVibrate = await Haptics.canVibrate();
  }

  static buttonPressed() {
    if (_canVibrate) {
      Haptics.vibrate(HapticsType.medium);
    }
  }

  static successPressed() {
    if (_canVibrate) {
      Haptics.vibrate(HapticsType.success);
    }
  }
}
