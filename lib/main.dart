// lib/main.dart
// Entry point of the Dude Routine Tracker app
// Sets up storage, notifications, and runs the app

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/report_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

/// App entry point
void main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode (optional, remove if you want landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize services ──────────────────────────
  // 1. Initialize local storage (Hive)
  await StorageService.init();

  // 2. Initialize notifications
  await NotificationService().init();

  // 3. Schedule all daily notifications on first launch
  //    (They persist even if app is closed)
  await NotificationService().scheduleAllRoutineNotifications();

  // ── Start the app ────────────────────────────────
  runApp(const DudeRoutineApp());
}

/// Root widget of the application
class DudeRoutineApp extends StatelessWidget {
  const DudeRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dude Routine',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: AppTheme.darkTheme,        // Always use dark theme
      home: const MainNavigator(),
    );
  }
}

/// Main navigation shell with bottom nav bar
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0; // Which tab is active

  // The four main screens
  final List<Widget> _screens = const [
    DashboardScreen(),
    ReportScreen(),
    NotesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the currently selected screen
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(
            top: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.today,
                  label: 'Today',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.bar_chart,
                  label: 'Report',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.edit_note,
                  label: 'Notes',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual bottom nav item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.accent : AppTheme.textSecond,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.accent : AppTheme.textSecond,
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
