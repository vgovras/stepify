import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import 'widgets/greeting_header.dart';

/// Recipe catalog — the main entry screen of the app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.screenHorizontal,
                    24,
                    AppSizes.screenHorizontal,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(child: GreetingHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenHorizontal,
                    20,
                    AppSizes.screenHorizontal,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _SearchBar(
                      onTap: () => showAppToast(context, '🔍 Пошук в розробці'),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.screenHorizontal,
                    24,
                    AppSizes.screenHorizontal,
                    12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Рецепти',
                      style: TextStyle(
                        fontSize: AppSizes.fontSectionTitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tx,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                  ),
                  sliver: SliverList.builder(
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.recipes[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < state.recipes.length - 1 ? 16 : 24,
                        ),
                        child: RecipeCard(
                          recipe: recipe,
                          onTap: () => context.push('/recipe/${recipe.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.s1,
          border: Border.all(color: AppColors.br),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 20, color: AppColors.t3),
            SizedBox(width: 10),
            Text(
              'Пошук рецептів...',
              style: TextStyle(fontSize: 14, color: AppColors.t3),
            ),
          ],
        ),
      ),
    );
  }
}
