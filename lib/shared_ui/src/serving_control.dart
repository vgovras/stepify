import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/core.dart';

/// +/- stepper for serving count.
class ServingControl extends StatelessWidget {
  const ServingControl({
    super.key,
    required this.servings,
    required this.onChanged,
  });

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.s1,
        border: Border.all(color: AppColors.br),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Порції',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.tx,
            ),
          ),
          Row(
            children: [
              _RoundButton(
                label: '−',
                onTap: servings > 1 ? () => onChanged(servings - 1) : null,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 22,
                child: Text(
                  '$servings',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: AppSizes.fontServingValue,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ac,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RoundButton(
                label: '+',
                onTap: servings < 12 ? () => onChanged(servings + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.s2,
          border: Border.all(color: AppColors.br, width: 1.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            color: onTap != null ? AppColors.tx : AppColors.t3,
          ),
        ),
      ),
    );
  }
}
