/// Data module — repositories and local storage abstractions.
///
/// Depends only on core. Exposes repository interfaces and the
/// DataModule registrar. Internal data sources (hardcoded recipes,
/// Hive adapters) are NOT exported.
library;

export 'src/data_module.dart' show DataModule;
export 'src/repositories/recipe_repository.dart';
export 'src/repositories/shopping_repository.dart';
export 'src/repositories/user_prefs_repository.dart';
