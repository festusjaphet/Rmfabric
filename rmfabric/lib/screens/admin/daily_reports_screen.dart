import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/helpers/date_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';
import '../../widgets/chart_widget.dart';

class DailyReportsScreen extends StatelessWidget {
  const DailyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);
    final reports = reportProv.recentDailyReports;

    // Chart data (most recent 7 closed days)
    final labels = reports
        .map((r) => r.date.substring(5))
        .toList()
        .reversed
        .toList();
    final salesData = reports
        .map((r) => r.totalSales)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Reports')),
      body: reports.isEmpty
          ? const Center(
              child: Text(
                'No reports yet. Close a day to generate one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                SalesTrendChart(
                  values: salesData.cast<double>(),
                  labels: labels,
                  title: 'Sales Trend (Last ${reports.length} Days)',
                ),
                const SizedBox(height: 8),
                ...reports.map(
                  (r) => ReportCard(
                    title: DateHelpers.formatDate(DateTime.parse(r.date)),
                    subtitle: 'Closed by: ${r.closedBy}',
                    totalSales: r.totalSales,
                    totalCost: r.totalCost,
                    totalExpenses: r.totalExpenses,
                    totalProfit: r.totalProfit,
                    transactions: r.totalTransactions,
                  ),
                ),
              ],
            ),
    );
  }
}
