// lib/screens/report_screen.dart
// Monthly report showing stats, streaks, and bar chart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  Map<String, double> _chartData = {};
  double _monthlyAvg = 0;
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear  = now.year;
    _selectedMonth = now.month;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final chartData = StorageService.getMonthlyChartData(
      _selectedYear,
      _selectedMonth,
    );

    // Calculate monthly average (only days with data)
    final daysWithData = chartData.values.where((v) => v > 0).toList();
    final avg = daysWithData.isEmpty
        ? 0.0
        : daysWithData.reduce((a, b) => a + b) / daysWithData.length;

    final streak = StorageService.calcStreak();

    setState(() {
      _chartData = chartData;
      _monthlyAvg = avg;
      _streak = streak;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          // Month selector
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<int>(
              value: _selectedMonth,
              dropdownColor: AppTheme.bgCard,
              underline: const SizedBox(),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              items: List.generate(12, (i) {
                return DropdownMenuItem(
                  value: i + 1,
                  child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMonth = val);
                  _loadData();
                }
              },
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month title
                  Text(
                    DateFormat('MMMM yyyy')
                        .format(DateTime(_selectedYear, _selectedMonth)),
                    style: const TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stats Cards ────────────────────────
                  Row(
                    children: [
                      _StatCard(
                        label: 'Monthly Avg',
                        value: '${_monthlyAvg.toStringAsFixed(0)}%',
                        icon: Icons.bar_chart,
                        color: AppTheme.accentBlue,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Current Streak',
                        value: '$_streak days 🔥',
                        icon: Icons.local_fire_department,
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Bar Chart ──────────────────────────
                  const Text(
                    'DAILY COMPLETION',
                    style: TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBarChart(),
                  const SizedBox(height: 24),

                  // ── Day-by-day list ────────────────────
                  const Text(
                    'DAY BREAKDOWN',
                    style: TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDayList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart() {
    // Only show days that have data
    final entries = _chartData.entries
        .where((e) => e.value > 0)
        .toList();

    if (entries.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: const Center(
          child: Text(
            'No data for this month yet.\nStart tracking your routine!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecond),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < entries.length) {
                    final day = entries[index].key.split('-').last;
                    return Text(
                      day,
                      style: const TextStyle(
                        color: AppTheme.textSecond,
                        fontSize: 9,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (i) {
            final percent = entries[i].value;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: percent,
                  color: percent >= 80
                      ? AppTheme.accent
                      : percent >= 50
                          ? AppTheme.accentBlue
                          : AppTheme.accentRed,
                  width: 6,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppTheme.divider.withOpacity(0.3),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDayList() {
    final today = DateTime.now();
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: daysInMonth,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
        itemBuilder: (context, index) {
          final day = index + 1;
          final dateStr =
              '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          final percent = _chartData[dateStr] ?? 0;
          final isToday = dateStr ==
              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
          final isFuture = DateTime(_selectedYear, _selectedMonth, day)
              .isAfter(DateTime(today.year, today.month, today.day));

          final color = percent >= 80
              ? AppTheme.accent
              : percent >= 50
                  ? AppTheme.accentBlue
                  : percent > 0
                      ? AppTheme.accentRed
                      : AppTheme.textSecond;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Day number
                SizedBox(
                  width: 32,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isToday
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontWeight: isToday
                          ? FontWeight.w800
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Day name
                SizedBox(
                  width: 36,
                  child: Text(
                    DateFormat.E()
                        .format(DateTime(_selectedYear, _selectedMonth, day)),
                    style: const TextStyle(
                      color: AppTheme.textSecond,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isFuture ? 0 : percent / 100,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFuture ? Colors.transparent : color,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Percentage text
                SizedBox(
                  width: 40,
                  child: Text(
                    isFuture
                        ? '--'
                        : percent == 0
                            ? 'No data'
                            : '${percent.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isFuture ? AppTheme.textSecond : color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecond,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
