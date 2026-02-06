import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'time_model.g.dart';

@HiveType(typeId: 3)
class TimeSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectName;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  TimeSession({
    required this.id,
    required this.projectName,
    required this.startTime,
    this.endTime,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}
