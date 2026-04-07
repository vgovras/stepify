import 'package:flutter/foundation.dart';

import 'step_note.dart';
import 'step_timer.dart';

@immutable
class RecipeStep {
  const RecipeStep({
    required this.id,
    required this.weight,
    required this.text,
    required this.waitTimer,
    this.deps = const [],
    this.timerDep,
    this.note,
    this.timer,
  });

  final int id;

  /// Sort priority — lower weight = shown earlier.
  final int weight;

  /// IDs of prerequisite steps that must be done.
  final List<int> deps;

  /// ID of a step whose background timer must have completed.
  final int? timerDep;

  final String text;
  final StepNote? note;
  final StepTimer? timer;

  /// Whether the user must wait for this step's timer to complete
  /// before advancing.
  final bool waitTimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStep && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RecipeStep($id, w:$weight, "$text")';
}
