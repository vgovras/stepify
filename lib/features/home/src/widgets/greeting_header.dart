import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/core.dart';

/// Greeting block with personalized hello and heading.
///
/// Displays "Привіт, Славе 👋" in muted text and a two-line
/// heading where "готувати?" is highlighted in gold.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Привіт, Славе 👋',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.t2,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Що будемо\n',
                style: GoogleFonts.playfairDisplay(
                  fontSize: AppSizes.fontScreenTitle,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.tx,
                ),
              ),
              TextSpan(
                text: 'готувати?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: AppSizes.fontScreenTitle,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.ac,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
