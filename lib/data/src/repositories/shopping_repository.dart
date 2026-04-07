import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../core/core.dart';
import '../local/shopping_box.dart';

/// A single item in the shopping list.
@immutable
class ShoppingItem {
  const ShoppingItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.isBought = false,
  });

  /// Creates a [ShoppingItem] from a decoded JSON map.
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      category: IngredientCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => IngredientCategory.other,
      ),
      isBought: json['isBought'] as bool? ?? false,
    );
  }

  final String name;

  /// Human-readable quantity string, e.g. "500 г" or "за смаком".
  final String quantity;

  final IngredientCategory category;

  /// Whether the item has been marked as bought.
  final bool isBought;

  /// Returns a copy with the given fields replaced.
  ShoppingItem copyWith({
    String? name,
    String? quantity,
    IngredientCategory? category,
    bool? isBought,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isBought: isBought ?? this.isBought,
    );
  }

  /// Serializes this item to a JSON-encodable map.
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'category': category.name,
    'isBought': isBought,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          quantity == other.quantity &&
          category == other.category &&
          isBought == other.isBought;

  @override
  int get hashCode => Object.hash(name, quantity, category, isBought);

  @override
  String toString() => 'ShoppingItem($name, $quantity)';
}

/// Abstraction for shopping list persistence.
///
/// MVP uses [HiveShoppingRepository] with JSON strings in a
/// Hive box. Swap implementation for cloud sync post-MVP.
abstract class ShoppingRepository {
  /// Returns all shopping items in insertion order.
  List<ShoppingItem> getAll();

  /// Adds a single item to the list.
  Future<void> add(ShoppingItem item);

  /// Toggles the [isBought] flag at [index].
  Future<void> toggleBought(int index);

  /// Removes all items from the list.
  Future<void> clear();
}

/// Hive-backed implementation of [ShoppingRepository].
///
/// Each item is stored as a JSON-encoded string at an integer
/// key matching its index.
class HiveShoppingRepository implements ShoppingRepository {
  HiveShoppingRepository({Box<String>? box})
    : _box = box ?? Hive.box<String>(shoppingBoxName);

  final Box<String> _box;

  @override
  List<ShoppingItem> getAll() {
    return _box.values
        .map((json) {
          try {
            final decoded = jsonDecode(json) as Map<String, dynamic>;
            return ShoppingItem.fromJson(decoded);
          } on FormatException {
            return null;
          }
        })
        .whereType<ShoppingItem>()
        .toList();
  }

  @override
  Future<void> add(ShoppingItem item) async {
    await _box.add(jsonEncode(item.toJson()));
  }

  @override
  Future<void> toggleBought(int index) async {
    if (index < 0 || index >= _box.length) return;
    final key = _box.keyAt(index) as int;
    final raw = _box.get(key);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final item = ShoppingItem.fromJson(decoded);
    final toggled = item.copyWith(isBought: !item.isBought);
    await _box.put(key, jsonEncode(toggled.toJson()));
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
