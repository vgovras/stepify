/// Core module — shared domain types, constants, and pure utilities.
///
/// This module has zero Flutter dependencies in its pure logic files.
/// All feature modules depend on this module.
library;

export 'src/constants/app_colors.dart';
export 'src/constants/app_durations.dart';
export 'src/constants/app_sizes.dart';
export 'src/models/enums.dart';
export 'src/models/ingredient.dart';
export 'src/models/recipe.dart';
export 'src/models/recipe_step.dart';
export 'src/models/step_note.dart';
export 'src/models/step_state.dart';
export 'src/models/step_timer.dart';
export 'src/models/timer_state.dart';
export 'src/utils/serving_scaler.dart';
export 'src/utils/time_format.dart';
