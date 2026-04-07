import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';
import '../done_cubit.dart';

/// Bottom sheet for rating a recipe after completion.
class RatingSheet extends StatefulWidget {
  const RatingSheet({super.key});

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _stars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenHorizontal,
        20,
        AppSizes.screenHorizontal,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.br,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Оцініть рецепт',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.tx,
            ),
          ),
          const SizedBox(height: 16),
          // Star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < _stars;
              return GestureDetector(
                onTap: () => setState(() => _stars = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: filled ? AppColors.ac : AppColors.t3,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Comment field
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: AppColors.tx),
            decoration: InputDecoration(
              hintText: 'Залишити коментар...',
              hintStyle: const TextStyle(color: AppColors.t3),
              filled: true,
              fillColor: AppColors.s2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.br),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.br),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.ac),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          PrimaryButton(
            label: 'Надіслати',
            isDisabled: _stars == 0,
            onPressed: _stars == 0
                ? null
                : () {
                    context.read<DoneCubit>().submitRating(
                      _stars,
                      _commentController.text,
                    );
                    Navigator.of(context).pop();
                    showAppToast(context, 'Дякуємо за оцінку!');
                  },
          ),
        ],
      ),
    );
  }
}
