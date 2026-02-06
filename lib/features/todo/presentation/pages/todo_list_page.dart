import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/todo/data/models/todo_model.dart';
import 'package:omnipro_productivity/features/todo/presentation/providers/todo_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export Todos',
            onPressed: () => _exportTodos(context, todos),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _filterTodos(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Tasks')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first task'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                final isOverdue = !todo.isCompleted && todo.dueDate.isBefore(DateTime.now());
                
                return Dismissible(
                  key: Key(todo.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(todoProvider.notifier).deleteTodo(todo.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task "${todo.title}" deleted')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (val) {
                          ref.read(todoProvider.notifier).toggleTodo(todo.id);
                        },
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat.yMMMd().format(todo.dueDate)}',
                            style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              todo.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          color: todo.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          ref.read(todoProvider.notifier).toggleTodo(todo.id);
                        },
                      ),
                      onTap: () => _showEditTodoDialog(context, ref, todo),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _exportTodos(BuildContext context, List<Todo> todos) {
    final completed = todos.where((t) => t.isCompleted).toList();
    final pending = todos.where((t) => !t.isCompleted).toList();
    
    final buffer = StringBuffer();
    buffer.writeln('=== TODO LIST EXPORT ===');
    buffer.writeln('Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}');
    buffer.writeln('');
    
    buffer.writeln('COMPLETED (${completed.length}):');
    for (final todo in completed) {
      buffer.writeln('[✓] ${todo.title} - Due: ${DateFormat.yMMMd().format(todo.dueDate)}');
    }
    buffer.writeln('');
    
    buffer.writeln('PENDING (${pending.length}):');
    for (final todo in pending) {
      buffer.writeln('[ ] ${todo.title} - Due: ${DateFormat.yMMMd().format(todo.dueDate)}');
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('Total: ${todos.length} tasks');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context);
                Share.share(buffer.toString(), subject: 'My Todo List');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to clipboard'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _filterTodos(BuildContext context, WidgetRef ref, String value) {
    // Implement filtering logic if needed
  }

  void _showEditTodoDialog(BuildContext context, WidgetRef ref, Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    String selectedCategory = todo.category;
    DateTime selectedDate = todo.dueDate;
    int selectedPriority = todo.priority;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['General', 'Work', 'Personal', 'Urgent', 'Shopping']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => selectedCategory = val ?? 'General',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Low')),
                  const DropdownMenuItem(value: 1, child: Text('Medium')),
                  const DropdownMenuItem(value: 2, child: Text('High')),
                ],
                onChanged: (val) => selectedPriority = val ?? 1,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat.yMMMd().format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final updated = Todo(
                    id: todo.id,
                    title: titleController.text,
                    description: todo.description,
                    dueDate: selectedDate,
                    isCompleted: todo.isCompleted,
                    priority: selectedPriority,
                    category: selectedCategory,
                  );
                  ref.read(todoProvider.notifier).updateTodo(updated);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedCategory = 'General';
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['General', 'Work', 'Personal', 'Urgent', 'Shopping']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => selectedCategory = val ?? 'General',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat.yMMMd().format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final todo = Todo.create(
                    title: titleController.text,
                    dueDate: selectedDate,
                    category: selectedCategory,
                  );
                  ref.read(todoProvider.notifier).addTodo(todo);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
