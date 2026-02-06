import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/todo/data/models/todo_model.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]) {
    _loadTodos();
  }

  final _box = HiveService().getBox('todos');

  void _loadTodos() {
    state = _box.values.cast<Todo>().toList();
  }

  Future<void> addTodo(Todo todo) async {
    await _box.put(todo.id, todo);
    state = [...state, todo];
  }

  Future<void> toggleTodo(String id) async {
    final todo = _box.get(id) as Todo?;
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      await todo.save();
      state = _box.values.cast<Todo>().toList();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    await _box.put(updatedTodo.id, updatedTodo);
    state = [
      for (final todo in state)
        if (todo.id == updatedTodo.id) updatedTodo else todo
    ];
  }
}
