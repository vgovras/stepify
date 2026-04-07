import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class Ingredient {
  const Ingredient({
    required this.name,
    required this.unit,
    required this.category,
    this.amount,
  });

  final String name;

  /// Null means "за смаком" (to taste).
  final double? amount;

  final String unit;
  final IngredientCategory category;

  Ingredient copyWith({
    String? name,
    double? Function()? amount,
    String? unit,
    IngredientCategory? category,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount != null ? amount() : this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          amount == other.amount &&
          unit == other.unit &&
          category == other.category;

  @override
  int get hashCode => Object.hash(name, amount, unit, category);

  @override
  String toString() => 'Ingredient($name, $amount $unit)';
}
