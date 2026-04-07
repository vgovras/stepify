import 'package:flutter/foundation.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';

/// Immutable state for the shopping list screen.
@immutable
class ShoppingState {
  const ShoppingState({required this.items});

  /// Creates an empty initial state.
  const ShoppingState.initial() : items = const [];

  /// All shopping items in insertion order.
  final List<ShoppingItem> items;

  /// Items grouped by [IngredientCategory] for display.
  ///
  /// Only categories that have at least one item are included.
  Map<IngredientCategory, List<ShoppingItem>> get grouped {
    final map = <IngredientCategory, List<ShoppingItem>>{};
    for (final item in items) {
      (map[item.category] ??= []).add(item);
    }
    return map;
  }

  /// Total number of items in the list.
  int get totalCount => items.length;

  /// Returns a copy with the given fields replaced.
  ShoppingState copyWith({List<ShoppingItem>? items}) {
    return ShoppingState(items: items ?? this.items);
  }
}
