import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import '../data/data.dart';
import '../features/checklist/checklist.dart';
import '../features/cook/cook.dart';
import '../features/detail/detail.dart';
import '../features/done/done.dart';
import '../features/home/home.dart';
import '../features/profile/profile.dart';
import '../features/shopping/shopping.dart';
import '../shared/shared.dart';
import 'shell_scaffold.dart';

final appRouter = GoRouter(
  routes: [
    // Shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(routes: HomeModule.routes),
        // Tab 1: Search (placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const Scaffold(
                body: Center(
                  child: Text(
                    'Пошук в розробці',
                    style: TextStyle(color: AppColors.t3),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Tab 2: Shopping
        StatefulShellBranch(routes: ShoppingModule.routes()),
        // Tab 3: Profile
        StatefulShellBranch(routes: ProfileModule.routes()),
      ],
    ),

    // Standalone routes (no bottom nav)
    ...DetailModule.routes,
    GoRoute(
      path: '/recipe/:id/checklist',
      builder: (context, state) {
        final recipeId = state.pathParameters['id'] ?? '';
        final di = GetIt.instance;
        final recipe = di.get<RecipeRepository>().getById(recipeId);
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: Text('Рецепт не знайдено')),
          );
        }
        final servings =
            int.tryParse(state.uri.queryParameters['servings'] ?? '') ??
            recipe.baseServings;
        return BlocProvider(
          create: (_) =>
              ChecklistCubit(recipe: recipe, currentServings: servings),
          child: const ChecklistScreen(),
        );
      },
    ),
    GoRoute(
      path: '/recipe/:id/cook',
      builder: (context, state) {
        final recipeId = state.pathParameters['id'] ?? '';
        final di = GetIt.instance;
        final recipe = di.get<RecipeRepository>().getById(recipeId);
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: Text('Рецепт не знайдено')),
          );
        }
        return BlocProvider(
          create: (_) => CookCubit(
            recipe: recipe,
            notificationService: di.get<NotificationService>(),
          ),
          child: const CookScreen(),
        );
      },
    ),
    ...DoneModule.routes,
  ],
);
