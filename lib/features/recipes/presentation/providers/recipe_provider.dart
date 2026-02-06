import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/recipes/data/models/recipe_model.dart';
import 'package:omnipro_productivity/features/recipes/data/repositories/recipe_repository.dart';
import 'package:uuid/uuid.dart';

final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier(RecipeRepository());
});

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository _repository;

  RecipeNotifier(this._repository) : super([]) {
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    state = await _repository.getRecipes();
  }

  Future<void> addRecipe(String title, String ingredients, String steps) async {
    final recipe = Recipe(
      id: const Uuid().v4(),
      title: title,
      ingredients: ingredients,
      steps: steps,
    );
    await _repository.insertRecipe(recipe);
    _loadRecipes();
  }
}
