import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import 'detail_cubit.dart';
import 'detail_screen.dart';

/// Registers detail module dependencies and routes.
abstract final class DetailModule {
  /// Registers [DetailCubit] as a factory with a [Recipe] parameter.
  static void register(GetIt di) {
    di.registerFactoryParam<DetailCubit, Recipe, void>(
      (recipe, _) => DetailCubit(recipe: recipe),
    );
  }

  /// GoRouter route for the recipe detail screen.
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final repo = GetIt.instance.get<RecipeRepository>();
        final recipe = repo.getById(id);
        if (recipe == null) {
          return const _NotFoundScreen();
        }
        return BlocProvider(
          create: (_) => GetIt.instance.get<DetailCubit>(param1: recipe),
          child: const DetailScreen(),
        );
      },
    ),
  ];
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Рецепт не знайдено')));
  }
}
