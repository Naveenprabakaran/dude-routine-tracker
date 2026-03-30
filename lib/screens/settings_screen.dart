// lib/screens/settings_screen.dart
// Settings screen for managing notifications and app preferences

import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isRescheduling = false;

  Future<void> _rescheduleNotifications() async {
    setState(() => _isRescheduling = true);
    await NotificationService().scheduleAllRoutineNotifications();
    setState(() => _isRescheduling = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications rescheduled! ✅'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _cancelNotifications() async {
    await NotificationService().cancelAllNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications cancelled'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Notifications Section ───────────────────
          _SectionHeader(label: 'NOTIFICATIONS'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Daily Reminders',
                    style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: const Text('Get notified at task times',
                    style: TextStyle(color: AppTheme.textSecond, fontSize: 12)),
                value: _notificationsEnabled,
                activeColor: AppTheme.accent,
                onChanged: (val) async {
                  setState(() => _notificationsEnabled = val);
                  if (val) {
                    await _rescheduleNotifications();
                  } else {
                    await _cancelNotifications();
                  }
                },
              ),
              const Divider(height: 1, color: AppTheme.divider),
              ListTile(
                leading: const Icon(Icons.refresh, color: AppTheme.accentBlue),
                title: const Text('Reschedule All Notifications',
                    style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: const Text('Use this if notifications stopped working',
                    style: TextStyle(color: AppTheme.textSecond, fontSize: 12)),
                trailing: _isRescheduling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppTheme.textSecond),
                onTap: _isRescheduling ? null : _rescheduleNotifications,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Schedule Section ────────────────────────
          _SectionHeader(label: 'YOUR ROUTINE SCHEDULE'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: _buildScheduleList(),
          ),

          const SizedBox(height: 24),

          // ── About Section ───────────────────────────
          _SectionHeader(label: 'ABOUT'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppTheme.textSecond),
                title: Text('Dude Routine Tracker',
                    style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: Text('Version 1.0.0',
                    style: TextStyle(color: AppTheme.textSecond, fontSize: 12)),
              ),
              const Divider(height: 1, color: AppTheme.divider),
              const ListTile(
                leading: Icon(Icons.storage, color: AppTheme.textSecond),
                title: Text('Storage',
                    style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: Text('All data stored locally on your device',
                    style: TextStyle(color: AppTheme.textSecond, fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleList() {
    final tasks = [
      {'time': '6:30 AM',  'name': 'Wake Up',   'emoji': '☀️'},
      {'time': '8:15 AM',  'name': 'ABC Juice', 'emoji': '🥤'},
      {'time': '9:00 AM',  'name': 'Breakfast', 'emoji': '🍳'},
      {'time': '1:30 PM',  'name': 'Lunch',     'emoji': '🍱'},
      {'time': '4:20 PM',  'name': 'Banana',    'emoji': '🍌'},
      {'time': '5:15 PM',  'name': 'Coffee',    'emoji': '☕'},
      {'time': '7:15 PM',  'name': 'Gym',       'emoji': '💪'},
      {'time': '9:00 PM',  'name': 'Dinner',    'emoji': '🍽️'},
      {'time': '9:15 PM',  'name': 'GF Time',   'emoji': '💑'},
      {'time': '10:00 PM', 'name': 'Work',      'emoji': '💻'},
      {'time': '11:30 PM', 'name': 'Sleep',     'emoji': '😴'},
    ];

    return tasks.asMap().entries.map((entry) {
      final i = entry.key;
      final task = entry.value;
      final isLast = i == tasks.length - 1;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(task['emoji']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task['name']!,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                Text(
                  task['time']!,
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, color: AppTheme.divider, indent: 52),
        ],
      );
    }).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecond,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }
}
