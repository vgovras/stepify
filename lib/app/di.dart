import 'package:get_it/get_it.dart';

import '../data/data.dart';
import '../features/cook/cook.dart';
import '../features/detail/detail.dart';
import '../features/done/done.dart';
import '../features/home/home.dart';
import '../features/profile/profile.dart';
import '../features/shopping/shopping.dart';
import '../shared/shared.dart';

final di = GetIt.instance;

/// Registers all module dependencies in order.
Future<void> registerModules() async {
  // Infrastructure modules (no feature deps)
  SharedModule.register(di);
  await DataModule.register(di);

  // Initialize notification service
  await di.get<NotificationService>().init();

  // Feature modules
  HomeModule.register(di);
  DetailModule.register(di);
  CookModule.register(di);
  DoneModule.register(di);
  ShoppingModule.register(di);
  ProfileModule.register(di);
}
