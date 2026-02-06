import 'package:omnipro_productivity/core/storage/sqlite_service.dart';
import 'package:omnipro_productivity/features/notes/data/models/note_model.dart';
import 'package:sqflite/sqflite.dart';

class NoteRepository {
  final _dbService = SQLiteService();

  Future<List<Note>> getNotes() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<void> insertNote(Note note) async {
    final db = await _dbService.database;
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(Note note) async {
    final db = await _dbService.database;
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await _dbService.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
