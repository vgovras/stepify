import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'done_state.dart';

/// Manages the completion screen state and rating submission.
class DoneCubit extends Cubit<DoneState> {
  DoneCubit({
    required String recipeName,
    required int servings,
    required int timeMinutes,
  }) : super(
         DoneState(
           recipeName: recipeName,
           servings: servings,
           timeMinutes: timeMinutes,
         ),
       );

  /// Submits a user rating to local storage (stub for MVP).
  Future<void> submitRating(int stars, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'rating_${state.recipeName}';
    await prefs.setInt('${key}_stars', stars);
    await prefs.setString('${key}_comment', comment);
    emit(state.copyWith(hasRated: true));
  }
}
