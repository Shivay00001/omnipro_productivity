import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/expenses/data/models/expense_model.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  final _box = HiveService().getBox('expenses');

  void _loadExpenses() {
    state = _box.values.cast<Expense>().toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    state = [...state, expense];
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}
