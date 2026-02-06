import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double limit;

  @HiveField(3)
  final DateTime month;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
  });
}
