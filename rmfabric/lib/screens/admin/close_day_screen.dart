import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/helpers/date_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/sales_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';

class CloseDayScreen extends StatelessWidget {
  const CloseDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final salesProv = Provider.of<SalesProvider>(context);
    final expProv = Provider.of<ExpenseProvider>(context);
    final reportProv = Provider.of<ReportProvider>(context);

    final todayProfit = salesProv.todayTotalProfit - expProv.todayTotalExpenses;
    final isClosed = reportProv.isDayClosed;

    return Scaffold(
      appBar: AppBar(title: const Text('Close Day')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isClosed
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isClosed ? AppTheme.success : AppTheme.danger,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isClosed ? Icons.lock : Icons.lock_open_outlined,
                    color: isClosed ? AppTheme.success : AppTheme.danger,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isClosed ? 'Day is Closed' : 'Day is Open',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isClosed
                                ? AppTheme.success
                                : AppTheme.danger,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateHelpers.formatDate(DateTime.now()),
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Today's summary preview
            ReportCard(
              title: "Today's Summary Preview",
              totalSales: salesProv.todayTotalSales,
              totalCost: salesProv.todayTotalCost,
              totalExpenses: expProv.todayTotalExpenses,
              totalProfit: todayProfit,
              transactions: salesProv.todayTransactionCount,
            ),

            const SizedBox(height: 16),

            if (!isClosed) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppTheme.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once closed, no new sales or expenses can be added today.',
                        style: TextStyle(color: AppTheme.warning, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: reportProv.closingDay
                      ? null
                      : () => _confirmClose(
                          context,
                          auth,
                          salesProv,
                          expProv,
                          reportProv,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                  ),
                  icon: reportProv.closingDay
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock),
                  label: Text(
                    reportProv.closingDay
                        ? 'Closing...'
                        : 'Close Today\'s Business',
                  ),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.success,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Day successfully closed!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                        fontSize: 16,
                      ),
                    ),
                    if (reportProv.todayStatus?.closedAt != null)
                      Text(
                        'Closed at: ${DateHelpers.formatDateTime(reportProv.todayStatus!.closedAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClose(
    BuildContext context,
    app_auth.AuthProvider auth,
    SalesProvider salesProv,
    ExpenseProvider expProv,
    ReportProvider reportProv,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close Today\'s Business?'),
        content: const Text(
          'This will lock all sales and expenses for today and generate the daily report. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Yes, Close Day'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await reportProv.closeDay(
        adminId: auth.currentUser!.name,
        sales: salesProv.todaySales,
        expenses: expProv.todayExpenses,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Day closed successfully! ✅' : 'Failed to close day',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.danger,
          ),
        );
      }
    }
  }
}
