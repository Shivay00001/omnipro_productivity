import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/books/presentation/providers/book_provider.dart';
import 'package:file_picker/file_picker.dart';

class BookReaderPage extends ConsumerWidget {
  const BookReaderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(bookProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Book Reader')),
      body: books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No books added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add a PDF or EPUB file'),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _openBook(context, ref, book),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: const Icon(
                              Icons.book,
                              size: 64,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: book.progress.clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                  ),
                                ),
                                Text(
                                  '${(book.progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowedExtensions: ['pdf', 'epub'],
            type: FileType.custom,
          );
          if (result != null) {
            ref.read(bookProvider.notifier).addBook(
              result.files.single.name,
              result.files.single.path!,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openBook(BuildContext context, WidgetRef ref, dynamic book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.path.isNotEmpty)
              Text(
                'File: ${book.path.split('/').last}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            Text(
              'Progress: ${(book.progress * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateProgress(context, ref, book, 0.25);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.bookmark),
                    label: const Text('25%'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateProgress(context, ref, book, 0.50);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.auto_stories),
                    label: const Text('50%'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateProgress(context, ref, book, 0.75);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text('75%'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateProgress(context, ref, book, 1.0);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('100%'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateProgress(BuildContext context, WidgetRef ref, dynamic book, double progress) {
    ref.read(bookProvider.notifier).updateProgress(book.id, progress);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Progress updated to ${(progress * 100).toInt()}%')),
    );
  }
}
