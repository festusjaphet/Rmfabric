import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/date_helpers.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final double totalSales;
  final double totalCost;
  final double totalExpenses;
  final double totalProfit;
  final int transactions;
  final String? subtitle;

  const ReportCard({
    super.key,
    required this.title,
    required this.totalSales,
    required this.totalCost,
    required this.totalExpenses,
    required this.totalProfit,
    required this.transactions,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            const Divider(height: 20),
            _row('Sales Revenue', totalSales, AppTheme.primary),
            _row('Product Cost', totalCost, AppTheme.warning),
            _row('Expenses', totalExpenses, AppTheme.danger),
            const Divider(height: 16),
            _row(
              'Net Profit',
              totalProfit,
              totalProfit >= 0 ? AppTheme.success : AppTheme.danger,
              isBold: true,
            ),
            const SizedBox(height: 8),
            Text(
              '$transactions transactions',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            DateHelpers.formatCurrency(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
