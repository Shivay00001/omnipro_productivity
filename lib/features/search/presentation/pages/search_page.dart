import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/todo/data/models/todo_model.dart';
import 'package:omnipro_productivity/features/notes/data/models/note_model.dart';
import 'package:omnipro_productivity/features/expenses/data/models/expense_model.dart';
import 'package:omnipro_productivity/features/habits/data/models/habit_model.dart';
import 'package:omnipro_productivity/features/recipes/data/models/recipe_model.dart';
import 'package:omnipro_productivity/features/goals/data/models/goal_model.dart';
import 'package:omnipro_productivity/features/shopping/data/models/shopping_model.dart';
import 'package:omnipro_productivity/features/todo/presentation/providers/todo_provider.dart';
import 'package:omnipro_productivity/features/notes/presentation/providers/notes_provider.dart';
import 'package:omnipro_productivity/features/expenses/presentation/providers/expense_provider.dart';
import 'package:omnipro_productivity/features/habits/presentation/providers/habit_provider.dart';
import 'package:omnipro_productivity/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:omnipro_productivity/features/goals/presentation/providers/goal_provider.dart';
import 'package:omnipro_productivity/features/shopping/presentation/providers/shopping_provider.dart';

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final dynamic data;

  SearchResult(this.title, this.subtitle, this.type, this.data);
}

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final _controller = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final lowerQuery = query.toLowerCase();
    final List<SearchResult> results = [];

    final todos = ref.read(todoProvider);
    for (final todo in todos) {
      if (todo.title.toLowerCase().contains(lowerQuery) ||
          todo.description.toLowerCase().contains(lowerQuery) ||
          todo.category.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          todo.title,
          'Todo • ${todo.category} • ${todo.isCompleted ? 'Completed' : 'Pending'}',
          'todo',
          todo,
        ));
      }
    }

    final notes = ref.read(notesProvider);
    for (final note in notes) {
      if (note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          note.title,
          'Note • Last updated: ${note.updatedAt.toString().split(' ').first}',
          'note',
          note,
        ));
      }
    }

    final expenses = ref.read(expenseProvider);
    for (final expense in expenses) {
      if (expense.title.toLowerCase().contains(lowerQuery) ||
          expense.category.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          expense.title,
          'Expense • \$${expense.amount.toStringAsFixed(2)}',
          'expense',
          expense,
        ));
      }
    }

    final habits = ref.read(habitProvider);
    for (final habit in habits) {
      if (habit.name.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          habit.name,
          'Habit • ${habit.currentStreak} day streak',
          'habit',
          habit,
        ));
      }
    }

    final recipes = ref.read(recipeProvider);
    for (final recipe in recipes) {
      if (recipe.title.toLowerCase().contains(lowerQuery) ||
          recipe.ingredients.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          recipe.title,
          'Recipe • ${recipe.ingredients.split(',').length} ingredients',
          'recipe',
          recipe,
        ));
      }
    }

    final goals = ref.read(goalProvider);
    for (final goal in goals) {
      if (goal.title.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          goal.title,
          'Goal • ${(goal.progress * 100).toInt()}% complete',
          'goal',
          goal,
        ));
      }
    }

    final shoppingItems = ref.read(shoppingProvider);
    for (final item in shoppingItems) {
      if (item.name.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          item.name,
          'Shopping • ${item.isCompleted ? 'Completed' : 'Pending'}',
          'shopping',
          item,
        ));
      }
    }

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  Icon _getTypeIcon(String type) {
    switch (type) {
      case 'todo':
        return const Icon(Icons.check_circle, color: Colors.blue);
      case 'note':
        return const Icon(Icons.note, color: Colors.orange);
      case 'expense':
        return const Icon(Icons.attach_money, color: Colors.green);
      case 'habit':
        return const Icon(Icons.repeat, color: Colors.purple);
      case 'recipe':
        return const Icon(Icons.restaurant, color: Colors.red);
      case 'goal':
        return const Icon(Icons.flag, color: Colors.teal);
      case 'shopping':
        return const Icon(Icons.shopping_cart, color: Colors.amber);
      default:
        return const Icon(Icons.search, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search todos, notes, expenses...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          autofocus: true,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _controller.text.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Search your data',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todos, Notes, Expenses, Habits, Recipes, Goals, Shopping',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "${_controller.text}"',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: _getTypeIcon(result.type),
                          title: Text(result.title),
                          subtitle: Text(result.subtitle),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opened: ${result.title}')),
                            );
                          },
                        );
                      },
                    ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
