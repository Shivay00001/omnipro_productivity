import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 6)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double progress; // 0.0 to 1.0

  @HiveField(3)
  final List<String> milestones;

  Goal({
    required this.id,
    required this.title,
    this.progress = 0.0,
    this.milestones = const [],
  });
}
