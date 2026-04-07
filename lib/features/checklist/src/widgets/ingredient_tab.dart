import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';
import '../checklist_cubit.dart';
import '../checklist_state.dart';

/// Ingredient checklist tab — progress bar, checkable items,
/// and a ghost button to add missing items to shopping.
class IngredientTab extends StatelessWidget {
  const IngredientTab({super.key, required this.onAddToShopping});

  /// Called with the list of unchecked ingredients when the user
  /// taps the "add missing" button.
  final void Function(List<Ingredient> missing) onAddToShopping;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        final cubit = context.read<ChecklistCubit>();
        final progress = state.totalCount > 0
            ? state.checkedCount / state.totalCount
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  AppProgressBar(progress: progress),
                  const SizedBox(height: 8),
                  Text(
                    '${state.checkedCount} з '
                    '${state.totalCount} є вдома',
                    style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: AppColors.t2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                ),
                itemCount: state.scaledIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = state.scaledIngredients[index];
                  final isChecked = state.ingredientChecks[index];

                  return _ChecklistItem(
                    name: ingredient.name,
                    quantity: _formatQuantity(
                      ingredient.amount,
                      ingredient.unit,
                    ),
                    isChecked: isChecked,
                    onToggle: () => cubit.toggleIngredient(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
                vertical: 12,
              ),
              child: GhostButton(
                label: '\u{1F6D2} Додати відсутні до покупок',
                onPressed: () {
                  final missing = cubit.addMissingToShopping();
                  onAddToShopping(missing);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatQuantity(double? amount, String unit) {
    if (amount == null) return 'за смаком';
    final display = amount.truncateToDouble() == amount
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    return '$display $unit';
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.name,
    required this.quantity,
    required this.isChecked,
    required this.onToggle,
  });

  final String name;
  final String quantity;
  final bool isChecked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AppCheckbox(isChecked: isChecked),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: AppSizes.fontMain,
                  color: isChecked ? AppColors.t3 : AppColors.tx,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.t3,
                ),
              ),
            ),
            Text(
              quantity,
              style: TextStyle(
                fontSize: AppSizes.fontBody,
                color: isChecked ? AppColors.t3 : AppColors.t2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
