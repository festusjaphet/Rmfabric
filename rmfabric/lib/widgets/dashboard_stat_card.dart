import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/date_helpers.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isProfit;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (isProfit)
                Icon(
                  amount >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: amount >= 0 ? AppTheme.success : AppTheme.danger,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              DateHelpers.formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isProfit
                    ? (amount >= 0 ? AppTheme.success : AppTheme.danger)
                    : color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
