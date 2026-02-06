import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/notes/data/models/note_model.dart';
import 'package:omnipro_productivity/features/notes/data/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(NoteRepository());
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NoteRepository _repository;

  NotesNotifier(this._repository) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = await _repository.getNotes();
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insertNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      folder: note.folder,
      tags: note.tags,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );
    await _repository.updateNote(updatedNote);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }
}
