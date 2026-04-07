import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Gold-to-orange gradient button used as the main CTA.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.customStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;

  /// Override for special states (e.g. pause button with red style).
  final BoxDecoration? customStyle;

  @override
  Widget build(BuildContext context) {
    final decoration =
        customStyle ??
        BoxDecoration(
          gradient: isDisabled
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.ac, AppColors.ac2],
                ),
          color: isDisabled ? AppColors.s2 : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          boxShadow: isDisabled
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x40E8B44C),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
        );

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: AppSizes.fontButton,
            fontWeight: FontWeight.w700,
            color: isDisabled ? AppColors.t3 : AppColors.bg,
          ),
        ),
      ),
    );
  }
}
