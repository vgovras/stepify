import 'package:flutter/foundation.dart';

@immutable
class StepTimer {
  const StepTimer({
    required this.minutes,
    required this.label,
    required this.isBackground,
  });

  final int minutes;
  final String label;

  /// Whether this timer runs in the background while the user advances.
  final bool isBackground;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepTimer &&
          runtimeType == other.runtimeType &&
          minutes == other.minutes &&
          label == other.label &&
          isBackground == other.isBackground;

  @override
  int get hashCode => Object.hash(minutes, label, isBackground);
}
