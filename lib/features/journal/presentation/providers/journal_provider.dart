import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/journal/data/repositories/journal_repository.dart';
import 'package:uuid/uuid.dart';

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier(JournalRepository());
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final JournalRepository _repository;

  JournalNotifier(this._repository) : super([]) {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    state = await _repository.readEntries();
  }

  Future<void> addEntry(String content, String mood) async {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      content: content,
      mood: mood,
    );
    state = [...state, entry];
    await _repository.writeEntries(state);
  }
}
