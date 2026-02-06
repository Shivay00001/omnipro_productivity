import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/expenses/data/models/expense_model.dart';
import 'package:omnipro_productivity/features/expenses/presentation/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePage extends ConsumerWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: _buildChart(expenses),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                  trailing: Text(
                    '${expense.isIncome ? "+" : "-"}\$${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: expense.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChart(List<Expense> expenses) {
    if (expenses.isEmpty) return const Center(child: Text('No data'));
    
    // Simple bar chart showing total income vs total expense
    double totalIncome = 0;
    double totalExpense = 0;
    for (var e in expenses) {
      if (e.isIncome) totalIncome += e.amount;
      else totalExpense += e.amount;
    }

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalIncome, color: Colors.green)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalExpense, color: Colors.red)]),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('Income');
                if (value == 1) return const Text('Expense');
                return const Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                SwitchListTile(
                  title: const Text('Income?'),
                  value: isIncome,
                  onChanged: (val) => setState(() => isIncome = val),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (titleController.text.isNotEmpty && amount > 0) {
                    ref.read(expenseProvider.notifier).addExpense(
                      Expense.create(
                        title: titleController.text,
                        amount: amount,
                        date: DateTime.now(),
                        category: 'General',
                        isIncome: isIncome,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }
}
