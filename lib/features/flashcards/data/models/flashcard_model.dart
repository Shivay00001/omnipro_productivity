import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 4)
class Flashcard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String front;

  @HiveField(2)
  final String back;

  @HiveField(3)
  double easeFactor;

  @HiveField(4)
  int interval;

  @HiveField(5)
  int repetitions;

  @HiveField(6)
  DateTime nextReview;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    required this.nextReview,
  });
}
