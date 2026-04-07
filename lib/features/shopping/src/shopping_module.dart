import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data.dart';
import 'shopping_cubit.dart';
import 'shopping_screen.dart';

/// Registers shopping module dependencies and routes.
abstract final class ShoppingModule {
  /// Registers the [ShoppingCubit] singleton in [di].
  static void register(GetIt di) {
    di.registerLazySingleton<ShoppingCubit>(
      () => ShoppingCubit(repository: di.get<ShoppingRepository>()),
    );
  }

  /// GoRouter route for the shopping list tab.
  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/shopping',
        builder: (context, state) {
          final di = GetIt.instance;
          final cubit = di.get<ShoppingCubit>()..loadItems();
          return BlocProvider.value(
            value: cubit,
            child: const ShoppingScreen(),
          );
        },
      ),
    ];
  }
}
