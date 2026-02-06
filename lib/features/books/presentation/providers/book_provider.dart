import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/books/data/models/book_model.dart';
import 'package:uuid/uuid.dart';

final bookProvider = StateNotifierProvider<BookNotifier, List<Book>>((ref) {
  return BookNotifier();
});

class BookNotifier extends StateNotifier<List<Book>> {
  BookNotifier() : super([]) { _loadBooks(); }
  final _box = HiveService().getBox('books');

  void _loadBooks() {
    state = _box.values.cast<Book>().toList();
  }

  Future<void> addBook(String title, String path) async {
    final book = Book(id: const Uuid().v4(), title: title, filePath: path);
    await _box.put(book.id, book);
    _loadBooks();
  }

  Future<void> updateProgress(String id, double progress) async {
    final book = _box.get(id) as Book?;
    if (book != null) {
      book.progress = progress;
      await book.save();
      _loadBooks();
    }
  }

  Future<void> deleteBook(String id) async {
    await _box.delete(id);
    _loadBooks();
  }

  Future<void> updateBook(Book updatedBook) async {
    await _box.put(updatedBook.id, updatedBook);
    _loadBooks();
  }

  Book? getBookById(String id) {
    return _box.get(id) as Book?;
  }
}
