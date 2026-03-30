// lib/widgets/task_card.dart
// A single task card shown on the dashboard
// Displays task name, time, status, and YES/NO buttons

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(String status) onStatusChanged; // Called when YES/NO is tapped

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
  });

  // Map task name to an emoji icon for visual flair
  String _getEmoji(String taskName) {
    const emojis = {
      'Wake Up':   '☀️',
      'ABC Juice': '🥤',
      'Breakfast': '🍳',
      'Lunch':     '🍱',
      'Banana':    '🍌',
      'Coffee':    '☕',
      'Gym':       '💪',
      'Dinner':    '🍽️',
      'GF Time':   '💑',
      'Work':      '💻',
      'Sleep':     '😴',
    };
    return emojis[taskName] ?? '✅';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'yes';
    final isMissed    = task.status == 'no';
    final isPending   = task.status == 'pending';

    // Determine the left border/accent color based on status
    Color accentColor = AppTheme.textSecond;
    if (isCompleted) accentColor = AppTheme.accent;
    if (isMissed)    accentColor = AppTheme.accentRed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppTheme.accent.withOpacity(0.3)
              : isMissed
                  ? AppTheme.accentRed.withOpacity(0.3)
                  : AppTheme.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Left: Status indicator bar ──
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),

            // ── Center: Emoji + Task info ──
            Expanded(
              child: Row(
                children: [
                  // Emoji
                  Text(
                    _getEmoji(task.name),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  // Task name + time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: TextStyle(
                          color: isCompleted
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: isMissed
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.accentRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.timeLabel,
                        style: const TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right: YES / NO buttons or status badge ──
            if (isPending)
              _buildActionButtons()
            else
              _buildStatusBadge(isCompleted),
          ],
        ),
      ),
    );
  }

  /// YES / NO action buttons (shown when task is pending)
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NO button
        _ActionButton(
          label: 'NO',
          color: AppTheme.accentRed,
          onTap: () => onStatusChanged('no'),
        ),
        const SizedBox(width: 8),
        // YES button
        _ActionButton(
          label: 'YES',
          color: AppTheme.accent,
          onTap: () => onStatusChanged('yes'),
        ),
      ],
    );
  }

  /// Status badge shown after YES/NO is selected
  Widget _buildStatusBadge(bool isCompleted) {
    return GestureDetector(
      onTap: () => onStatusChanged('pending'), // Tap to reset to pending
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.accent.withOpacity(0.15)
              : AppTheme.accentRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? AppTheme.accent.withOpacity(0.4)
                : AppTheme.accentRed.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: isCompleted ? AppTheme.accent : AppTheme.accentRed,
            ),
            const SizedBox(width: 4),
            Text(
              isCompleted ? 'DONE' : 'MISSED',
              style: TextStyle(
                color: isCompleted ? AppTheme.accent : AppTheme.accentRed,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small YES/NO button widget
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
