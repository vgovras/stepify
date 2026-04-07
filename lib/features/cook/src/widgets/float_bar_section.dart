import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';
import '../cook_state.dart';

/// Renders active background timer float bars at the top of the cook screen.
class FloatBarSection extends StatelessWidget {
  const FloatBarSection({super.key, required this.state});

  final CookState state;

  @override
  Widget build(BuildContext context) {
    final bars = state.floatBarTimers;
    if (bars.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in bars.entries)
          FloatBar(
            label: _findLabel(entry.key),
            secondsRemaining: entry.value.secondsRemaining,
          ),
      ],
    );
  }

  String _findLabel(int stepId) {
    return state.recipe.steps
            .cast<RecipeStep?>()
            .firstWhere((s) => s?.id == stepId, orElse: () => null)
            ?.timer
            ?.label ??
        '';
  }
}
