import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/shopping/data/models/shopping_model.dart';
import 'package:omnipro_productivity/features/shopping/data/repositories/shopping_repository.dart';
import 'package:uuid/uuid.dart';

final shoppingProvider = StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>((ref) {
  return ShoppingNotifier(ShoppingRepository());
});

class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  final ShoppingRepository _repository;

  ShoppingNotifier(this._repository) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    state = await _repository.getItems();
  }

  Future<void> addItem(String name, {String category = 'General'}) async {
    final item = ShoppingItem(id: const Uuid().v4(), name: name, category: category);
    await _repository.insertItem(item);
    _loadItems();
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final updated = ShoppingItem(
      id: item.id,
      name: item.name,
      category: item.category,
      isCompleted: !item.isCompleted,
    );
    await _repository.updateItem(updated);
    _loadItems();
  }

  Future<void> updateItem(ShoppingItem item) async {
    await _repository.updateItem(item);
    _loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    state = state.where((item) => item.id != id).toList();
  }

  Future<void> clearCompleted() async {
    for (final item in state.where((item) => item.isCompleted)) {
      await _repository.deleteItem(item.id);
    }
    _loadItems();
  }
}
