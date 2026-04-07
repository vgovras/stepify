import 'package:get_it/get_it.dart';

import 'notification_service.dart';

/// Registers shared cross-cutting services.
abstract final class SharedModule {
  static void register(GetIt di) {
    di.registerLazySingleton<NotificationService>(NotificationService.new);
  }
}
