// lib/models/task_model.dart
// Represents a single routine task (e.g., "Wake up at 6:30")

import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id; // Unique ID like "2024-01-15_wake_up"

  @HiveField(1)
  String name; // "Wake Up"

  @HiveField(2)
  String timeLabel; // "6:30 AM"

  @HiveField(3)
  int hour; // 6

  @HiveField(4)
  int minute; // 30

  @HiveField(5)
  String date; // "2024-01-15"

  @HiveField(6)
  String status; // "pending", "yes", "no"

  @HiveField(7)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.name,
    required this.timeLabel,
    required this.hour,
    required this.minute,
    required this.date,
    this.status = 'pending',
    required this.createdAt,
  });
}
