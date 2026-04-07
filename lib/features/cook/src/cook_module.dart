import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import 'cook_cubit.dart';

/// Registers cook module dependencies.
abstract final class CookModule {
  static void register(GetIt di) {
    di.registerFactoryParam<CookCubit, Recipe, void>(
      (recipe, _) => CookCubit(
        recipe: recipe,
        notificationService: di.get<NotificationService>(),
      ),
    );
  }
}
