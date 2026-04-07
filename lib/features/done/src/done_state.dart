import 'package:flutter/foundation.dart';

/// Immutable state for the completion screen.
@immutable
class DoneState {
  const DoneState({
    required this.recipeName,
    required this.servings,
    required this.timeMinutes,
    this.hasRated = false,
  });

  /// Name of the completed recipe.
  final String recipeName;

  /// Number of servings cooked.
  final int servings;

  /// Total cooking time in minutes.
  final int timeMinutes;

  /// Whether the user has submitted a rating.
  final bool hasRated;

  /// Creates a copy with the given fields replaced.
  DoneState copyWith({
    String? recipeName,
    int? servings,
    int? timeMinutes,
    bool? hasRated,
  }) {
    return DoneState(
      recipeName: recipeName ?? this.recipeName,
      servings: servings ?? this.servings,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      hasRated: hasRated ?? this.hasRated,
    );
  }
}
