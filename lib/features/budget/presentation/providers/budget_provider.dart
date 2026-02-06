import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/budget/data/models/budget_model.dart';
import 'package:uuid/uuid.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<Budget>> {
  BudgetNotifier() : super([]) {
    _loadBudgets();
  }

  final _box = HiveService().getBox('budgets');

  void _loadBudgets() {
    state = _box.values.cast<Budget>().toList();
  }

  Future<void> setBudget(String category, double limit) async {
    final budget = Budget(
      id: const Uuid().v4(),
      category: category,
      limit: limit,
      month: DateTime.now(),
    );
    await _box.put(budget.id, budget);
    _loadBudgets();
  }
}
