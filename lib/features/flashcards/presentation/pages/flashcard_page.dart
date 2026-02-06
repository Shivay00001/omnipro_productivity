import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/flashcards/presentation/providers/flashcard_provider.dart';

class FlashcardPage extends ConsumerWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(flashcardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return ListTile(
            title: Text(card.front),
            subtitle: Text('Next review: ${card.nextReview.toString().split(' ').first}'),
            onTap: () => _studyCard(context, ref, card),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _studyCard(BuildContext context, WidgetRef ref, dynamic card) {
    bool showBack = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(showBack ? 'Answer' : 'Question'),
          content: Text(showBack ? card.back : card.front, style: const TextStyle(fontSize: 24)),
          actions: [
            if (!showBack)
              ElevatedButton(onPressed: () => setState(() => showBack = true), child: const Text('Show Answer'))
            else ...[
              const Text('Rate (0-5):'),
              Wrap(
                children: List.generate(6, (i) => IconButton(
                  icon: Text('$i'),
                  onPressed: () {
                    ref.read(flashcardProvider.notifier).reviewCard(card, i);
                    Navigator.pop(context);
                  },
                )),
              )
            ]
          ],
        );
      }),
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    final front = TextEditingController();
    final back = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')),
            TextField(controller: back, decoration: const InputDecoration(labelText: 'Back')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (front.text.isNotEmpty && back.text.isNotEmpty) {
                ref.read(flashcardProvider.notifier).createCard(front.text, back.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
