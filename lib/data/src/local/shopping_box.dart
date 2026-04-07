import 'package:hive/hive.dart';

/// Hive box name for persisting shopping list items.
const shoppingBoxName = 'shopping_list';

/// Opens the shopping list Hive box.
///
/// Call during app initialization before accessing
/// [HiveShoppingRepository].
Future<Box<String>> openShoppingBox() async {
  return Hive.openBox<String>(shoppingBoxName);
}
