import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool isIncome;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isIncome = false,
  });

  factory Expense.create({
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    bool isIncome = false,
  }) {
    return Expense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      category: category,
      isIncome: isIncome,
    );
  }
}
