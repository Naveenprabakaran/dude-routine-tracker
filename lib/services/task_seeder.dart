// lib/services/task_seeder.dart
// Creates the default daily tasks for a given date
// Think of this as the "template" for each day's routine

import '../models/task_model.dart';
import 'storage_service.dart';

class TaskSeeder {
  /// The master list of all daily tasks
  /// Edit this list to change your routine!
  static final List<Map<String, dynamic>> _taskTemplates = [
    {'name': 'Wake Up',   'hour': 6,  'minute': 30, 'label': '6:30 AM'},
    {'name': 'ABC Juice', 'hour': 8,  'minute': 15, 'label': '8:15 AM'},
    {'name': 'Breakfast', 'hour': 9,  'minute': 0,  'label': '9:00 AM'},
    {'name': 'Lunch',     'hour': 13, 'minute': 30, 'label': '1:30 PM'},
    {'name': 'Banana',    'hour': 16, 'minute': 20, 'label': '4:20 PM'},
    {'name': 'Coffee',    'hour': 17, 'minute': 15, 'label': '5:15 PM'},
    {'name': 'Gym',       'hour': 19, 'minute': 15, 'label': '7:15 PM'},
    {'name': 'Dinner',    'hour': 21, 'minute': 0,  'label': '9:00 PM'},
    {'name': 'GF Time',   'hour': 21, 'minute': 15, 'label': '9:15 PM'},
    {'name': 'Work',      'hour': 22, 'minute': 0,  'label': '10:00 PM'},
    {'name': 'Sleep',     'hour': 23, 'minute': 30, 'label': '11:30 PM'},
  ];

  /// Seed tasks for a specific date if they don't exist yet
  /// [dateStr] format: "2024-01-15"
  static Future<void> seedTasksForDate(String dateStr) async {
    // Don't re-seed if tasks already exist for this date
    if (StorageService.hasTasksForDate(dateStr)) return;

    for (int i = 0; i < _taskTemplates.length; i++) {
      final template = _taskTemplates[i];
      final taskName = template['name'] as String;

      // Create a unique ID by combining date + task name
      final id = '${dateStr}_${taskName.toLowerCase().replaceAll(' ', '_')}';

      final task = TaskModel(
        id: id,
        name: taskName,
        timeLabel: template['label'] as String,
        hour: template['hour'] as int,
        minute: template['minute'] as int,
        date: dateStr,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await StorageService.saveTask(task);
    }
  }

  /// Get the task templates (used for notification scheduling)
  static List<Map<String, dynamic>> get taskTemplates => _taskTemplates;
}
