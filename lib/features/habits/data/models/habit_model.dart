import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<DateTime> completedDays;

  @HiveField(3)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.completedDays,
    required this.createdAt,
  });

  int get currentStreak {
    if (completedDays.isEmpty) return 0;
    // Logic for streak calculation
    return completedDays.length; // Simplified for now
  }
}
