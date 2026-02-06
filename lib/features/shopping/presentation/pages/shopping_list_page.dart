import 'package:flutter/material.dart';
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

  Future<void> addItem(String name) async {
    final item = ShoppingItem(id: const Uuid().v4(), name: name);
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
}

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Add item'))),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      ref.read(shoppingProvider.notifier).addItem(controller.text);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CheckboxListTile(
                  title: Text(item.name),
                  value: item.isCompleted,
                  onChanged: (_) => ref.read(shoppingProvider.notifier).toggleItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
