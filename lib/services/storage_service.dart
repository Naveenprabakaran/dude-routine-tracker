// lib/services/storage_service.dart
// Handles all local data storage using Hive
// This is the single source of truth for all data in the app

import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/note_model.dart';

class StorageService {
  // Box names - like table names in a database
  static const String tasksBoxName = 'tasks';
  static const String notesBoxName = 'notes';

  // The actual Hive boxes
  static late Box<TaskModel> _tasksBox;
  static late Box<NoteModel> _notesBox;

  /// Initialize Hive and open all boxes
  /// Call this once in main() before runApp()
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register the custom type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteModelAdapter());
    }

    // Open the boxes
    _tasksBox = await Hive.openBox<TaskModel>(tasksBoxName);
    _notesBox = await Hive.openBox<NoteModel>(notesBoxName);
  }

  // ─────────────────────────────────────────
  // TASK OPERATIONS
  // ─────────────────────────────────────────

  /// Save or update a task for a specific date
  static Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  /// Get all tasks for a specific date (e.g., "2024-01-15")
  static List<TaskModel> getTasksForDate(String date) {
    return _tasksBox.values
        .where((task) => task.date == date)
        .toList()
      ..sort((a, b) {
        // Sort by time (hour first, then minute)
        if (a.hour != b.hour) return a.hour.compareTo(b.hour);
        return a.minute.compareTo(b.minute);
      });
  }

  /// Update the status of a task (yes/no/pending)
  static Future<void> updateTaskStatus(String taskId, String status) async {
    final task = _tasksBox.get(taskId);
    if (task != null) {
      task.status = status;
      await task.save();
    }
  }

  /// Get all tasks across all dates (for monthly reports)
  static List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }

  /// Get tasks for a specific month (e.g., year=2024, month=1)
  static List<TaskModel> getTasksForMonth(int year, int month) {
    final monthStr =
        '$year-${month.toString().padLeft(2, '0')}'; // "2024-01"
    return _tasksBox.values
        .where((task) => task.date.startsWith(monthStr))
        .toList();
  }

  /// Check if tasks have been seeded for a given date
  static bool hasTasksForDate(String date) {
    return _tasksBox.values.any((task) => task.date == date);
  }

  // ─────────────────────────────────────────
  // NOTE OPERATIONS
  // ─────────────────────────────────────────

  /// Save or update the note for a specific date
  static Future<void> saveNote(String date, String content) async {
    final existing = _notesBox.get(date);
    if (existing != null) {
      existing.content = content;
      existing.updatedAt = DateTime.now();
      await existing.save();
    } else {
      await _notesBox.put(
        date,
        NoteModel(date: date, content: content, updatedAt: DateTime.now()),
      );
    }
  }

  /// Get the note for a specific date (returns null if none)
  static NoteModel? getNoteForDate(String date) {
    return _notesBox.get(date);
  }

  /// Get all notes (for history view)
  static List<NoteModel> getAllNotes() {
    return _notesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest first
  }

  // ─────────────────────────────────────────
  // STATS CALCULATIONS
  // ─────────────────────────────────────────

  /// Calculate completion percentage for a list of tasks
  static double calcCompletionPercent(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((t) => t.status == 'yes').length;
    return (completed / tasks.length) * 100;
  }

  /// Calculate the current streak (consecutive days with >50% completion)
  static int calcStreak() {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final tasks = getTasksForDate(dateStr);
      if (tasks.isEmpty) break;
      final percent = calcCompletionPercent(tasks);
      if (percent >= 50) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get per-day completion data for the current month (for bar chart)
  static Map<String, double> getMonthlyChartData(int year, int month) {
    final Map<String, double> data = {};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int d = 1; d <= daysInMonth; d++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final tasks = getTasksForDate(dateStr);
      data[dateStr] = tasks.isEmpty ? 0 : calcCompletionPercent(tasks);
    }

    return data;
  }
}
