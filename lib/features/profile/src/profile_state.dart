import 'package:flutter/foundation.dart';

/// Immutable state for the user profile screen.
@immutable
class ProfileState {
  const ProfileState({
    required this.userName,
    required this.cookedCount,
    required this.savedCount,
  });

  /// Creates the initial state with default values.
  const ProfileState.initial() : userName = '', cookedCount = 0, savedCount = 0;

  /// The user's display name.
  final String userName;

  /// Total number of completed recipes.
  final int cookedCount;

  /// Number of saved/bookmarked recipes.
  final int savedCount;

  /// Returns a copy with the given fields replaced.
  ProfileState copyWith({String? userName, int? cookedCount, int? savedCount}) {
    return ProfileState(
      userName: userName ?? this.userName,
      cookedCount: cookedCount ?? this.cookedCount,
      savedCount: savedCount ?? this.savedCount,
    );
  }
}
