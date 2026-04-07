import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/text_styles.dart';
import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'detail_cubit.dart';
import 'detail_state.dart';

String _difficultyEmoji(Difficulty d) => switch (d) {
  Difficulty.easy => '🟢',
  Difficulty.medium => '🟡',
  Difficulty.hard => '🔴',
};

String _formatAmount(double? amount) {
  if (amount == null) return 'за смаком';
  if (amount.truncateToDouble() == amount) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(1);
}

/// Recipe detail screen with serving scaler and ingredient list.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) {
        final recipe = state.recipe;
        final cubit = context.read<DetailCubit>();

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroArea(
                  emoji: recipe.emoji,
                  gradientColors: recipe.gradientColors,
                  onBack: () => context.pop(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _RecipeHeader(recipe: recipe),
                    const SizedBox(height: 20),
                    ServingControl(
                      servings: state.currentServings,
                      onChanged: cubit.changeServings,
                    ),
                    const SizedBox(height: 16),
                    _RecipeStats(recipe: recipe),
                    const SizedBox(height: 24),
                    _IngredientsSection(ingredients: state.scaledIngredients),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: '🛒 Перевірити інгредієнти',
                      onPressed: () =>
                          context.push('/recipe/${recipe.id}/checklist'),
                    ),
                    const SizedBox(height: 24),
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

class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: AppTextStyles.heading24.copyWith(color: AppColors.tx),
        ),
        const SizedBox(height: 8),
        Text(
          '👨‍🍳 Традиційний рецепт'
          ' · ⭐ ${recipe.rating}'
          ' (${recipe.reviewCount} відгуки)',
          style: const TextStyle(fontSize: 13, color: AppColors.t2),
        ),
      ],
    );
  }
}

class _RecipeStats extends StatelessWidget {
  const _RecipeStats({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return StatGrid(
      cells: [
        StatCell(value: '${recipe.timeMinutes} хв', label: 'хвилин'),
        StatCell(value: '${recipe.kcalPerServing}', label: 'ккал/порц'),
        StatCell(
          value: _difficultyEmoji(recipe.difficulty),
          label: 'складність',
        ),
      ],
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Інгредієнти',
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.tx),
        ),
        const SizedBox(height: 12),
        ...ingredients.map(
          (ing) => _IngredientRow(
            name: ing.name,
            amount: _formatAmount(ing.amount),
            unit: ing.amount != null ? ing.unit : '',
          ),
        ),
      ],
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
          top: MediaQuery.paddingOf(context).top + 8,
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

class _RatingSection extends StatefulWidget {
  const _RatingSection();

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  int _rating = 0;

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
            (index) => GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Text(
                '★',
                style: TextStyle(
                  fontSize: 22,
                  color: index < _rating ? AppColors.ac : AppColors.t3,
                ),
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
