import 'package:flutter/material.dart';

import '../../app/text_styles.dart';
import '../../core/core.dart';

/// Grid of stats (time | kcal | difficulty) for the detail screen.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.cells});

  final List<StatCell> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.br),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.br,
                ),
              Expanded(child: _CellWidget(cell: cells[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class StatCell {
  const StatCell({required this.value, required this.label});
  final String value;
  final String label;
}

class _CellWidget extends StatelessWidget {
  const _CellWidget({required this.cell});
  final StatCell cell;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.s1,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cell.value,
            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ac),
          ),
          const SizedBox(height: 3),
          Text(
            cell.label,
            style: const TextStyle(fontSize: 10, color: AppColors.t3),
          ),
        ],
      ),
    );
  }
}
