import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/habits/data/models/habit_model.dart';
import 'package:uuid/uuid.dart';

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    _loadHabits();
  }

  final _box = HiveService().getBox('habits');

  void _loadHabits() {
    state = _box.values.cast<Habit>().toList();
  }

  Future<void> addHabit(String name) async {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      completedDays: [],
      createdAt: DateTime.now(),
    );
    await _box.put(habit.id, habit);
    state = [...state, habit];
  }

  Future<void> toggleHabitDay(String id, DateTime date) async {
    final habit = _box.get(id) as Habit?;
    if (habit != null) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (habit.completedDays.contains(dateOnly)) {
        habit.completedDays.remove(dateOnly);
      } else {
        habit.completedDays.add(dateOnly);
      }
      await habit.save();
      _loadHabits();
    }
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    state = state.where((h) => h.id != id).toList();
  }
}
