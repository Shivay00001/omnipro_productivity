import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'book_model.g.dart';

@HiveType(typeId: 7)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  double progress; // 0.0 to 1.0

  Book({
    required this.id,
    required this.title,
    required this.filePath,
    this.progress = 0.0,
  });
}
