import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/recipes/presentation/providers/recipe_provider.dart';

class RecipePage extends ConsumerWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Book')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe.title),
            subtitle: Text('Ingredients: ${recipe.ingredients.split(',').take(3).join(', ')}...'),
            onTap: () => _showRecipeDetails(context, recipe),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeDialog(context, ref),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, dynamic recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(recipe.ingredients),
              const SizedBox(height: 16),
              const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(recipe.steps),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final ing = TextEditingController();
    final steps = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: ing, decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'), maxLines: 3),
              TextField(controller: steps, decoration: const InputDecoration(labelText: 'Steps'), maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (title.text.isNotEmpty) {
                ref.read(recipeProvider.notifier).addRecipe(title.text, ing.text, steps.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
