import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data.dart';
import 'profile_cubit.dart';
import 'profile_screen.dart';

/// Registers profile module dependencies and routes.
abstract final class ProfileModule {
  /// Registers the [ProfileCubit] singleton in [di].
  static void register(GetIt di) {
    di.registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(repository: di.get<UserPrefsRepository>()),
    );
  }

  /// GoRouter route for the profile tab.
  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final di = GetIt.instance;
          final cubit = di.get<ProfileCubit>()..loadProfile();
          return BlocProvider.value(value: cubit, child: const ProfileScreen());
        },
      ),
    ];
  }
}
