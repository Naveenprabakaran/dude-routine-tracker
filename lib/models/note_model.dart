// lib/models/note_model.dart
// Represents a daily note written by the user

import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject {
  @HiveField(0)
  String date; // "2024-01-15"

  @HiveField(1)
  String content; // The actual note text

  @HiveField(2)
  DateTime updatedAt;

  NoteModel({
    required this.date,
    required this.content,
    required this.updatedAt,
  });
}
