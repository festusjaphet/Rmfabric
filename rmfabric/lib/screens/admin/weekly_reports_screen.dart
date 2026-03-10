import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/helpers/date_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';

class WeeklyReportsScreen extends StatefulWidget {
  const WeeklyReportsScreen({super.key});

  @override
  State<WeeklyReportsScreen> createState() => _WeeklyReportsScreenState();
}

class _WeeklyReportsScreenState extends State<WeeklyReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ReportProvider>(
        context,
        listen: false,
      ).loadWeeklyReport(_selectedDate),
    );
  }

  Future<void> _pickWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Pick any day in the week',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (mounted) {
        Provider.of<ReportProvider>(
          context,
          listen: false,
        ).loadWeeklyReport(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);
    final start = DateHelpers.startOfWeek(_selectedDate);
    final end = DateHelpers.endOfWeek(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickWeek,
            tooltip: 'Pick week',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.primary.withValues(alpha: 0.06),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_view_week,
                  color: AppTheme.primary,
                ),
                title: Text(
                  '${DateHelpers.formatDate(start)}  →  ${DateHelpers.formatDate(end)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: _pickWeek,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (reportProv.loading)
              const Center(child: CircularProgressIndicator())
            else if (reportProv.currentReport == null)
              const Center(
                child: Text(
                  'No data for selected week.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ReportCard(
                title: 'Weekly Summary',
                subtitle: 'Week: ${reportProv.currentReport!.periodId}',
                totalSales: reportProv.currentReport!.totalSales,
                totalCost: reportProv.currentReport!.totalCost,
                totalExpenses: reportProv.currentReport!.totalExpenses,
                totalProfit: reportProv.currentReport!.totalProfit,
                transactions: reportProv.currentReport!.totalTransactions,
              ),
          ],
        ),
      ),
    );
  }
}
