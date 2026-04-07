import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import 'shopping_state.dart';

/// Manages the persistent shopping list.
///
/// Reads from and writes to [ShoppingRepository] on every
/// mutation to stay in sync with local storage.
class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit({required ShoppingRepository repository})
    : _repository = repository,
      super(const ShoppingState.initial());

  final ShoppingRepository _repository;

  /// Loads all items from local storage.
  void loadItems() {
    final items = _repository.getAll();
    emit(state.copyWith(items: items));
  }

  /// Adds a list of [ShoppingItem]s to the shopping list.
  Future<void> addItems(List<ShoppingItem> items) async {
    await _repository.addAll(items);
    loadItems();
  }

  /// Toggles the [isBought] flag of the item at [index].
  Future<void> toggleBought(int index) async {
    await _repository.toggleBought(index);
    // Update in-place instead of reloading all items
    final updated = List<ShoppingItem>.from(state.items);
    if (index >= 0 && index < updated.length) {
      updated[index] = updated[index].copyWith(
        isBought: !updated[index].isBought,
      );
      emit(state.copyWith(items: updated));
    }
  }

  /// Removes all items from the shopping list.
  Future<void> clearAll() async {
    await _repository.clear();
    loadItems();
  }
}
