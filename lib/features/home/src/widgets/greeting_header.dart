import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Greeting block with personalized hello and heading.
///
/// Displays "Привіт, Славе 👋" in muted text and a two-line
/// heading where "готувати?" is highlighted in gold.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Привіт, Славе 👋',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.t2,
          ),
        ),
        SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Що будемо\n',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: AppSizes.fontScreenTitle,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.tx,
                ),
              ),
              TextSpan(
                text: 'готувати?',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
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
