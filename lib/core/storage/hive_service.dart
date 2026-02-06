import 'package:hive_flutter/hive_flutter.dart';

import 'package:omnipro_productivity/features/books/data/models/book_model.dart';
import 'package:omnipro_productivity/features/budget/data/models/budget_model.dart';
import 'package:omnipro_productivity/features/expenses/data/models/expense_model.dart';
import 'package:omnipro_productivity/features/flashcards/data/models/flashcard_model.dart';
import 'package:omnipro_productivity/features/goals/data/models/goal_model.dart';
import 'package:omnipro_productivity/features/habits/data/models/habit_model.dart';
import 'package:omnipro_productivity/features/time_tracker/data/models/time_model.dart';
import 'package:omnipro_productivity/features/alarm/data/models/extreme_alarm_model.dart';
import 'package:omnipro_productivity/features/books/data/models/book_model.dart';
import 'package:omnipro_productivity/features/todo/data/models/todo_model.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Future<void> init() async {
    // Register Adapters here
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(TimeSessionAdapter());
    Hive.registerAdapter(FlashcardAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(ExtremeAlarmAdapter());
    
    // Open basic boxes
    await Hive.openBox('settings');
    await Hive.openBox('todos');
    await Hive.openBox('expenses');
    await Hive.openBox('habits');
    await Hive.openBox('timers');
    await Hive.openBox('flashcards');
    await Hive.openBox('budgets');
    await Hive.openBox('goals');
    await Hive.openBox('books');
    await Hive.openBox('extreme_alarms');
    await Hive.openBox('wallet');
  }

  Box getBox(String name) => Hive.box(name);
}
