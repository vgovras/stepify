import 'package:flutter/material.dart';

import '../../app/text_styles.dart';
import '../../core/core.dart';
import 'emoji_text.dart';

/// Recipe card for the home catalog.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  String get _diffLabel => switch (recipe.difficulty) {
    Difficulty.easy => 'Легко',
    Difficulty.medium => 'Середньо',
    Difficulty.hard => 'Складно',
  };

  Color get _diffColor => switch (recipe.difficulty) {
    Difficulty.easy => AppColors.gr,
    Difficulty.medium => AppColors.ac,
    Difficulty.hard => AppColors.rd,
  };

  @override
  Widget build(BuildContext context) {
    final gradStart = recipe.gradientColors != null
        ? Color(recipe.gradientColors!.$1)
        : AppColors.bg.withValues(alpha: 0.6);
    final gradEnd = recipe.gradientColors != null
        ? Color(recipe.gradientColors!.$2)
        : AppColors.bg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.s1,
          border: Border.all(color: AppColors.br),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with emoji
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [gradStart, gradEnd],
                    ),
                  ),
                  child: EmojiText(recipe.emoji, fontSize: 72),
                ),
                // Gradient fade at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.s1.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
                // Difficulty badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _diffColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _diffLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bg.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.tx,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetaItem(
                        icon: Icons.timer_outlined,
                        text: '${recipe.timeMinutes} хв',
                      ),
                      const SizedBox(width: 12),
                      _MetaItem(
                        icon: Icons.local_fire_department,
                        text: '${recipe.kcalPerServing} ккал',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '★★★★★ ${recipe.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ac,
                        ),
                      ),
                    ],
                  ),
                  if (recipe.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final tag in recipe.tags) _Tag(text: tag),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.t2),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.t2),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.s2,
        border: Border.all(color: AppColors.br),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.t2),
      ),
    );
  }
}
