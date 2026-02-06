import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/goals/data/models/goal_model.dart';
import 'package:uuid/uuid.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]) { _loadGoals(); }
  final _box = HiveService().getBox('goals');

  void _loadGoals() {
    state = _box.values.cast<Goal>().toList();
  }

  Future<void> addGoal(String title) async {
    final goal = Goal(id: const Uuid().v4(), title: title);
    await _box.put(goal.id, goal);
    _loadGoals();
  }
}
