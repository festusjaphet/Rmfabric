import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';

class MonthlyReportsScreen extends StatefulWidget {
  const MonthlyReportsScreen({super.key});

  @override
  State<MonthlyReportsScreen> createState() => _MonthlyReportsScreenState();
}

class _MonthlyReportsScreenState extends State<MonthlyReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ReportProvider>(
        context,
        listen: false,
      ).loadMonthlyReport(_selectedDate),
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Pick any day in the month',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (mounted) {
        Provider.of<ReportProvider>(
          context,
          listen: false,
        ).loadMonthlyReport(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
            tooltip: 'Pick month',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              color: Colors.teal.withValues(alpha: 0.06),
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.teal),
                title: Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: _pickMonth,
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
                  'No data for selected month.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ReportCard(
                title: 'Monthly Summary',
                subtitle: 'Month: ${reportProv.currentReport!.periodId}',
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
