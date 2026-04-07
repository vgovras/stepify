import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data.dart';
import 'home_cubit.dart';
import 'home_screen.dart';

/// Registers home module dependencies and routes.
abstract final class HomeModule {
  /// Registers [HomeCubit] in the DI container.
  static void register(GetIt di) {
    di.registerFactory<HomeCubit>(
      () => HomeCubit(recipeRepository: di.get<RecipeRepository>()),
    );
  }

  /// GoRouter route for the home screen.
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.instance.get<HomeCubit>()..loadRecipes(),
        child: const HomeScreen(),
      ),
    ),
  ];
}
