import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/helpers/date_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';

class CustomReportsScreen extends StatefulWidget {
  const CustomReportsScreen({super.key});

  @override
  State<CustomReportsScreen> createState() => _CustomReportsScreenState();
}

class _CustomReportsScreenState extends State<CustomReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _generate() async {
    if (_startDate == null || _endDate == null) return;
    await Provider.of<ReportProvider>(context, listen: false).loadCustomReport(
      DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0),
      DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Start Date',
                    value: _startDate,
                    onTap: _pickStartDate,
                    icon: Icons.calendar_today,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: 'End Date',
                    value: _endDate,
                    onTap: _pickEndDate,
                    icon: Icons.event,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  (_startDate == null || _endDate == null || reportProv.loading)
                  ? null
                  : _generate,
              icon: reportProv.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.bar_chart),
              label: Text(
                reportProv.loading ? 'Generating...' : 'Generate Report',
              ),
            ),
            const SizedBox(height: 16),
            if (reportProv.currentReport != null)
              ReportCard(
                title: 'Custom Period Report',
                subtitle: reportProv.currentReport!.periodId,
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

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value != null ? DateHelpers.formatDate(value!) : 'Tap to select',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: value != null ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
