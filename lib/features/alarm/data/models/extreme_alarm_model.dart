import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'extreme_alarm_model.g.dart';

@HiveType(typeId: 8)
class ExtremeAlarm extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime alarmTime;

  @HiveField(2)
  bool isActive;

  @HiveField(3)
  double stakeAmount; // Default 100

  @HiveField(4)
  double penaltyPerMinute; // Default 5

  @HiveField(5)
  String requiredEssayTopic;

  @HiveField(6)
  int minWordCount;

  ExtremeAlarm({
    required this.id,
    required this.alarmTime,
    this.isActive = true,
    this.stakeAmount = 100.0,
    this.penaltyPerMinute = 5.0,
    this.requiredEssayTopic = 'Why being productive is important for my future',
    this.minWordCount = 50,
  });

  factory ExtremeAlarm.create({
    required DateTime time,
    double stake = 100.0,
    double penalty = 5.0,
  }) {
    return ExtremeAlarm(
      id: const Uuid().v4(),
      alarmTime: time,
      stakeAmount: stake,
      penaltyPerMinute: penalty,
    );
  }
}
