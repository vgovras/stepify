import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Reusable checkbox with rounded corners and check icon.
///
/// Used in ingredient checklist and shopping list screens.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.gr : Colors.transparent,
        border: Border.all(
          color: isChecked ? AppColors.gr : AppColors.br,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 14, color: AppColors.bg)
          : null,
    );
  }
}
