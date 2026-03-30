// lib/screens/notes_screen.dart
// Daily notes screen where users can write journal entries
// Notes are stored locally and persist between app sessions

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/note_model.dart';
import '../theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  String _todayStr = '';
  bool _isSaving = false;
  bool _showHistory = false;
  List<NoteModel> _history = [];

  @override
  void initState() {
    super.initState();
    _todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadNote();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load today's note from storage
  void _loadNote() {
    final note = StorageService.getNoteForDate(_todayStr);
    if (note != null) {
      _controller.text = note.content;
    }
    _history = StorageService.getAllNotes();
    setState(() {});
  }

  /// Save the note to storage
  Future<void> _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    await StorageService.saveNote(_todayStr, _controller.text.trim());
    _history = StorageService.getAllNotes();
    setState(() => _isSaving = false);

    // Show a brief confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note saved! ✅'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Notes'),
        actions: [
          // Toggle history/today view
          TextButton.icon(
            onPressed: () {
              setState(() => _showHistory = !_showHistory);
            },
            icon: Icon(
              _showHistory ? Icons.edit_note : Icons.history,
              color: AppTheme.accent,
              size: 18,
            ),
            label: Text(
              _showHistory ? 'Today' : 'History',
              style: const TextStyle(color: AppTheme.accent),
            ),
          ),
        ],
      ),
      body: _showHistory ? _buildHistory() : _buildEditor(),
    );
  }

  /// Today's note editor
  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prompt text
          const Text(
            'How was your day? Any wins, struggles, or thoughts?',
            style: TextStyle(
              color: AppTheme.textSecond,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                height: 1.6,
              ),
              decoration: const InputDecoration(
                hintText: 'Start writing...\n\n'
                    'e.g. Crushed the gym today! Missed lunch though. '
                    'Need to meal prep on Sundays...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 14,
                  height: 1.6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppTheme.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppTheme.accent, width: 1.5),
                ),
                filled: true,
                fillColor: AppTheme.bgCard,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveNote,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.bgDark,
                      ),
                    )
                  : const Icon(Icons.save, color: AppTheme.bgDark, size: 18),
              label: Text(
                _isSaving ? 'Saving...' : 'Save Note',
                style: const TextStyle(
                  color: AppTheme.bgDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Note history list
  Widget _buildHistory() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📓', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'No notes yet.\nStart writing your daily thoughts!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecond, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final note = _history[index];
        final isToday = note.date == _todayStr;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? AppTheme.accent.withOpacity(0.3)
                  : AppTheme.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatDate(note.date),
                    style: TextStyle(
                      color: isToday ? AppTheme.accent : AppTheme.textSecond,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
