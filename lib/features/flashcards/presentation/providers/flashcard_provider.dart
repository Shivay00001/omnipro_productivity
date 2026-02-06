import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/flashcards/data/models/flashcard_model.dart';
import 'package:uuid/uuid.dart';

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Flashcard>>((ref) {
  return FlashcardNotifier();
});

class FlashcardNotifier extends StateNotifier<List<Flashcard>> {
  FlashcardNotifier() : super([]) {
    _loadCards();
  }

  final _box = HiveService().getBox('flashcards');

  void _loadCards() {
    state = _box.values.cast<Flashcard>().toList();
  }

  Future<void> createCard(String front, String back) async {
    final card = Flashcard(
      id: const Uuid().v4(),
      front: front,
      back: back,
      nextReview: DateTime.now(),
    );
    await _box.put(card.id, card);
    _loadCards();
  }

  Future<void> reviewCard(Flashcard card, int quality) async {
    // SM-2 Algorithm
    if (quality >= 3) {
      if (card.repetitions == 0) {
        card.interval = 1;
      } else if (card.repetitions == 1) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * card.easeFactor).round();
      }
      card.repetitions++;
      card.easeFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (card.easeFactor < 1.3) card.easeFactor = 1.3;
    } else {
      card.repetitions = 0;
      card.interval = 1;
    }
    card.nextReview = DateTime.now().add(Duration(days: card.interval));
    await card.save();
    _loadCards();
  }
}
