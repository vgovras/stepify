import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'detail_cubit.dart';
import 'detail_state.dart';

/// Recipe detail screen with serving scaler and ingredient list.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  String _difficultyEmoji(Difficulty d) => switch (d) {
    Difficulty.easy => '🟢',
    Difficulty.medium => '🟡',
    Difficulty.hard => '🔴',
  };

  String _formatAmount(double? amount) {
    if (amount == null) return 'за смаком';
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) {
        final recipe = state.recipe;
        final cubit = context.read<DetailCubit>();
        final ingredients = state.scaledIngredients;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              // Hero area
              SliverToBoxAdapter(
                child: _HeroArea(
                  emoji: recipe.emoji,
                  gradientColors: recipe.gradientColors,
                  onBack: () => context.pop(),
                ),
              ),
              // Body
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    // Recipe name
                    Text(
                      recipe.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Author line
                    Text(
                      '👨‍🍳 Традиційний рецепт'
                      ' · ⭐ ${recipe.rating}'
                      ' (${recipe.reviewCount} відгуки)',
                      style: const TextStyle(fontSize: 13, color: AppColors.t2),
                    ),
                    const SizedBox(height: 20),
                    // Serving control
                    ServingControl(
                      servings: state.currentServings,
                      onChanged: cubit.changeServings,
                    ),
                    const SizedBox(height: 16),
                    // Stat grid
                    StatGrid(
                      cells: [
                        StatCell(
                          value: '${recipe.timeMinutes} хв',
                          label: 'хвилин',
                        ),
                        StatCell(
                          value: '${recipe.kcalPerServing}',
                          label: 'ккал/порц',
                        ),
                        StatCell(
                          value: _difficultyEmoji(recipe.difficulty),
                          label: 'складність',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Ingredients section
                    Text(
                      'Інгредієнти',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: AppSizes.fontSectionTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Ingredient list
                    ...ingredients.map(
                      (ing) => _IngredientRow(
                        name: ing.name,
                        amount: _formatAmount(ing.amount),
                        unit: ing.amount != null ? ing.unit : '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    // CTA button
                    PrimaryButton(
                      label: '🛒 Перевірити інгредієнти',
                      onPressed: () =>
                          context.go('/recipe/${recipe.id}/checklist'),
                    ),
                    const SizedBox(height: 24),
                    // Rating stars (visual only)
                    const _RatingSection(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroArea extends StatelessWidget {
  const _HeroArea({
    required this.emoji,
    required this.onBack,
    this.gradientColors,
  });

  final String emoji;
  final VoidCallback onBack;
  final (int, int)? gradientColors;

  @override
  Widget build(BuildContext context) {
    final gradStart = gradientColors != null
        ? Color(gradientColors!.$1)
        : AppColors.s2;
    final gradEnd = gradientColors != null
        ? Color(gradientColors!.$2)
        : AppColors.bg;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradStart, gradEnd, AppColors.bg],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 88)),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.br),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.tx,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.amount,
    required this.unit,
  });

  final String name;
  final String amount;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.s1,
          border: Border.all(color: AppColors.br),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          children: [
            const _GoldDot(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 14, color: AppColors.tx),
              ),
            ),
            Text(
              unit.isNotEmpty ? '$amount $unit' : amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.t2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldDot extends StatelessWidget {
  const _GoldDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.ac,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.author, required this.text});

  final String author;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.s1,
        border: Border.all(color: AppColors.br),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tx,
                ),
              ),
              const Text(
                '★★★★★',
                style: TextStyle(fontSize: 11, color: AppColors.ac),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.t2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ваша оцінка',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.tx,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) => Text(
              '★',
              style: TextStyle(
                fontSize: 22,
                color: index < 4 ? AppColors.ac : AppColors.t3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Reviews
        const _ReviewCard(
          author: 'Оксана Г.',
          text:
              'Підказка про картоплю в холодній воді — '
              'врятувало! Паралельні кроки заощадили '
              'купу часу.',
        ),
        const SizedBox(height: 8),
        const _ReviewCard(
          author: 'Михайло Р.',
          text:
              'Вперше зварив борщ і вийшло ідеально. '
              'Таймери — просто вогонь 🔥',
        ),
      ],
    );
  }
}
