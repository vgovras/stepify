import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/text_styles.dart';
import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'checklist_cubit.dart';
import 'checklist_state.dart';
import 'widgets/ingredient_tab.dart';
import 'widgets/steps_tab.dart';

/// Pre-cooking checklist screen with two tabs: ingredients
/// and steps overview.
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        final cubit = context.read<ChecklistCubit>();

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _Header(onBack: () => context.pop()),
                const SizedBox(height: 12),
                _TabBar(activeTab: state.activeTab, onSwitch: cubit.switchTab),
                const SizedBox(height: 4),
                Expanded(
                  child: IndexedStack(
                    index: state.activeTab,
                    children: [
                      IngredientTab(
                        onAddToShopping: (missing) {
                          showAppToast(
                            context,
                            '\u{1F6D2} ${missing.length} '
                            'позицій додано до списку покупок',
                          );
                        },
                      ),
                      const StepsTab(),
                    ],
                  ),
                ),
                _Footer(
                  recipeId: state.recipe.id,
                  servings: state.currentServings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.screenHorizontal,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.t2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Перед готуванням',
            style: AppTextStyles.stepTitle.copyWith(color: AppColors.tx),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.activeTab, required this.onSwitch});

  final int activeTab;
  final ValueChanged<int> onSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.screenHorizontal,
      ),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.s1,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.br),
        ),
        child: Row(
          children: [
            _TabButton(
              label: '\u{1F6D2} Інгредієнти',
              isActive: activeTab == 0,
              onTap: () => onSwitch(0),
            ),
            _TabButton(
              label: '\u{1F4CB} Кроки',
              isActive: activeTab == 1,
              onTap: () => onSwitch(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.s2 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall - 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontBody,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.tx : AppColors.t3,
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.recipeId, required this.servings});

  final String recipeId;
  final int servings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenHorizontal,
        8,
        AppSizes.screenHorizontal,
        16,
      ),
      child: PrimaryButton(
        label: '\u{1F373} Починаємо готувати \u{2192}',
        onPressed: () {
          context.go(
            '/recipe/$recipeId/cook'
            '?servings=$servings',
          );
        },
      ),
    );
  }
}
