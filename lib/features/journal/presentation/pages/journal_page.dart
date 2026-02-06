import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/journal/presentation/providers/journal_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class JournalListPage extends ConsumerWidget {
  const JournalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Journal')),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ListTile(
            title: Text(DateFormat.yMMMd().format(entry.date)),
            subtitle: Text('Mood: ${entry.mood}'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Markdown(data: entry.content),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context, ref),
        child: const Icon(Icons.edit_note),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();
    String mood = 'Happy';

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
                controller: contentController,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'Write your heart out (Markdown supported)'),
              ),
              DropdownButton<String>(
                value: mood,
                onChanged: (val) {
                  if (val != null) mood = val;
                },
                items: ['Happy', 'Neutral', 'Sad', 'Angry', 'Excited']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (contentController.text.isNotEmpty) {
                    ref.read(journalProvider.notifier).addEntry(contentController.text, mood);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Entry'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
