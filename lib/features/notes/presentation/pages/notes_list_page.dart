import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/notes/data/models/note_model.dart';
import 'package:omnipro_productivity/features/notes/presentation/providers/notes_provider.dart';
import 'package:intl/intl.dart';

class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(
              'Last updated: ${DateFormat.yMMMd().add_jm().format(note.updatedAt)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ref.read(notesProvider.notifier).deleteNote(note.id),
            ),
            onTap: () => _showNoteEditor(context, ref, note: note),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNoteEditor(BuildContext context, WidgetRef ref, {Note? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'Content (Markdown support coming soon)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (note == null) {
                    ref.read(notesProvider.notifier).addNote(
                      titleController.text,
                      contentController.text,
                    );
                  } else {
                    ref.read(notesProvider.notifier).updateNote(
                      Note(
                        id: note.id,
                        title: titleController.text,
                        content: contentController.text,
                        createdAt: note.createdAt,
                        updatedAt: DateTime.now(),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(note == null ? 'Save Note' : 'Update Note'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
