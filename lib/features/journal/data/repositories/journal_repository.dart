import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final String mood;

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'content': content,
    'mood': mood,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    content: json['content'],
    mood: json['mood'],
  );
}

class JournalRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/journal.json');
  }

  Future<List<JournalEntry>> readEntries() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => JournalEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> writeEntries(List<JournalEntry> entries) async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }
}
