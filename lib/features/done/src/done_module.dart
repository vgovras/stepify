import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data.dart';
import 'done_cubit.dart';
import 'done_screen.dart';

/// Registers done module dependencies and routes.
abstract final class DoneModule {
  /// Registers [DoneCubit] in the DI container.
  static void register(GetIt di) {
    di.registerFactoryParam<DoneCubit, _DoneParams, void>(
      (params, _) => DoneCubit(
        recipeName: params.recipeName,
        servings: params.servings,
        timeMinutes: params.timeMinutes,
      ),
    );
  }

  /// GoRouter route for the completion screen.
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/recipe/:id/done',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final repo = GetIt.instance.get<RecipeRepository>();
        final recipe = repo.getById(id);
        return BlocProvider(
          create: (_) => GetIt.instance.get<DoneCubit>(
            param1: _DoneParams(
              recipeName: recipe?.name ?? 'Рецепт',
              servings: recipe?.baseServings ?? 4,
              timeMinutes: recipe?.timeMinutes ?? 0,
            ),
          ),
          child: const DoneScreen(),
        );
      },
    ),
  ];
}

/// Parameter bundle for [DoneCubit] factory registration.
@immutable
class _DoneParams {
  const _DoneParams({
    required this.recipeName,
    required this.servings,
    required this.timeMinutes,
  });

  final String recipeName;
  final int servings;
  final int timeMinutes;
}
