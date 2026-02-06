import 'package:omnipro_productivity/core/storage/sqlite_service.dart';
import 'package:omnipro_productivity/features/shopping/data/models/shopping_model.dart';
import 'package:sqflite/sqflite.dart';

class ShoppingRepository {
  final _dbService = SQLiteService();

  Future<List<ShoppingItem>> getItems() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('shopping_lists');
    return List.generate(maps.length, (i) => ShoppingItem.fromMap(maps[i]));
  }

  Future<void> insertItem(ShoppingItem item) async {
    final db = await _dbService.database;
    await db.insert('shopping_lists', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(ShoppingItem item) async {
    final db = await _dbService.database;
    await db.update('shopping_lists', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await _dbService.database;
    await db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
  }
}
