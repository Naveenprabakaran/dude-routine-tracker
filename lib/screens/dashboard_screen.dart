// lib/screens/dashboard_screen.dart
// Main screen showing today's tasks and progress
// This is the home screen users see when they open the app

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../services/task_seeder.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_ring.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TaskModel> _tasks = [];
  String _todayStr = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaysTasks();
  }

  /// Get today's date as "YYYY-MM-DD" string
  String _getDateStr(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Load or create today's tasks
  Future<void> _loadTodaysTasks() async {
    final today = DateTime.now();
    _todayStr = _getDateStr(today);

    // Seed today's tasks if they don't exist yet
    await TaskSeeder.seedTasksForDate(_todayStr);

    // Load tasks from storage
    final tasks = StorageService.getTasksForDate(_todayStr);

    if (mounted) {
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    }
  }

  /// Handle YES/NO button tap
  Future<void> _handleStatusChange(TaskModel task, String status) async {
    await StorageService.updateTaskStatus(task.id, status);
    // Reload tasks to reflect the change
    final updatedTasks = StorageService.getTasksForDate(_todayStr);
    setState(() {
      _tasks = updatedTasks;
    });
  }

  /// Calculate stats
  int get _completed => _tasks.where((t) => t.status == 'yes').length;
  int get _missed    => _tasks.where((t) => t.status == 'no').length;
  int get _pending   => _tasks.where((t) => t.status == 'pending').length;
  double get _percent =>
      _tasks.isEmpty ? 0 : (_completed / _tasks.length) * 100;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTodaysTasks,
        color: AppTheme.accent,
        backgroundColor: AppTheme.bgCard,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.bgDark,
              expandedHeight: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dude Routine',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: const TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress Section ──────────────────────
            SliverToBoxAdapter(
              child: _buildProgressSection(),
            ),

            // ── Stats Row ─────────────────────────────
            SliverToBoxAdapter(
              child: _buildStatsRow(),
            ),

            // ── Section header ─────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "TODAY'S TASKS",
                  style: TextStyle(
                    color: AppTheme.textSecond,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // ── Task List ─────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = _tasks[index];
                  return TaskCard(
                    task: task,
                    onStatusChanged: (status) =>
                        _handleStatusChange(task, status),
                  );
                },
                childCount: _tasks.length,
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// Big progress ring + percentage
  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          ProgressRing(
            percent: _percent,
            completed: _completed,
            total: _tasks.length,
          ),
          const SizedBox(height: 16),
          Text(
            _percent == 100
                ? '🔥 Perfect Day! Keep it up!'
                : _percent >= 80
                    ? '💪 Almost there!'
                    : _percent >= 50
                        ? '🚀 Good progress!'
                        : '⚡ Let\'s get going!',
            style: const TextStyle(
              color: AppTheme.textSecond,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Row showing Completed / Missed / Pending counts
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(
            label: 'Done',
            value: _completed,
            color: AppTheme.accent,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Missed',
            value: _missed,
            color: AppTheme.accentRed,
            icon: Icons.cancel_outlined,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Pending',
            value: _pending,
            color: AppTheme.textSecond,
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }
}

/// Small stat chip widget
class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecond,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
