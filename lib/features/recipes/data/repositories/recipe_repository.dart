import 'package:omnipro_productivity/core/storage/sqlite_service.dart';
import 'package:omnipro_productivity/features/recipes/data/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';

class RecipeRepository {
  final _dbService = SQLiteService();

  Future<List<Recipe>> getRecipes() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) => Recipe.fromMap(maps[i]));
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await _dbService.database;
    await db.insert('recipes', recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRecipe(String id) async {
    final db = await _dbService.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}
