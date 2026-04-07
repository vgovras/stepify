import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import 'shopping_cubit.dart';
import 'shopping_state.dart';

/// Category display metadata — emoji + Ukrainian label.
const _categoryLabels = {
  IngredientCategory.vegs: '\u{1F96C} Овочі',
  IngredientCategory.meat: '\u{1F969} М\u0027ясо',
  IngredientCategory.dairy: '\u{1F9C0} Молочне',
  IngredientCategory.eggs: '\u{1F95A} Яйця',
  IngredientCategory.other: '\u{1FAD9} Інше',
};

/// Shopping list screen — items grouped by category.
class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(totalCount: state.totalCount),
                Expanded(
                  child: state.items.isEmpty
                      ? const _EmptyState()
                      : _ItemList(state: state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenHorizontal,
        16,
        AppSizes.screenHorizontal,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Список покупок',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tx,
                ),
              ),
              const SizedBox(width: 10),
              if (totalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.s2,
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                    border: Border.all(color: AppColors.br),
                  ),
                  child: Text(
                    '\u{1F6D2} $totalCount позицій',
                    style: const TextStyle(
                      fontSize: AppSizes.fontLabel,
                      color: AppColors.t2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Перевірте, що все є перед походом',
            style: TextStyle(fontSize: AppSizes.fontBody, color: AppColors.t3),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Список порожній \u{1F6D2}',
        style: TextStyle(fontSize: AppSizes.fontButton, color: AppColors.t3),
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.state});

  final ShoppingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShoppingCubit>();
    final grouped = state.grouped;

    // Stable category order matching the enum declaration.
    final categories = IngredientCategory.values
        .where(grouped.containsKey)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.screenHorizontal,
        vertical: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final items = grouped[category]!;
        final label = _categoryLabels[category] ?? category.name;

        // Compute base index for this category's items within
        // the flat list, so toggleBought receives the correct
        // global index.
        final baseIndex = _globalIndex(state.items, category);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (catIndex > 0) const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontMain,
                fontWeight: FontWeight.w600,
                color: AppColors.t2,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < items.length; i++)
              _ShoppingItemRow(
                item: items[i],
                onToggle: () => cubit.toggleBought(baseIndex + i),
              ),
          ],
        );
      },
    );
  }

  /// Returns the global index of the first item with [category]
  /// in the flat [items] list.
  int _globalIndex(List<ShoppingItem> items, IngredientCategory category) {
    var count = 0;
    for (final item in state.items) {
      if (item.category == category) return count;
      count++;
    }
    return 0;
  }
}

class _ShoppingItemRow extends StatelessWidget {
  const _ShoppingItemRow({required this.item, required this.onToggle});

  final ShoppingItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isBought = item.isBought;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isBought ? AppColors.gr : Colors.transparent,
                border: Border.all(
                  color: isBought ? AppColors.gr : AppColors.br,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isBought
                  ? const Icon(Icons.check, size: 14, color: AppColors.bg)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: AppSizes.fontMain,
                  color: isBought ? AppColors.t3 : AppColors.tx,
                  decoration: isBought ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.t3,
                ),
              ),
            ),
            Text(
              item.quantity,
              style: TextStyle(
                fontSize: AppSizes.fontBody,
                color: isBought ? AppColors.t3 : AppColors.t2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
