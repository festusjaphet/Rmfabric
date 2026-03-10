import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/date_helpers.dart';
import '../../models/sale_model.dart';

class SaleCard extends StatelessWidget {
  final SaleModel sale;

  const SaleCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: const Icon(
            Icons.shopping_bag,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          sale.productName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Qty: ${sale.quantity}  •  ${sale.paymentMethod}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              DateHelpers.formatDateTime(sale.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateHelpers.formatCurrency(sale.totalSale),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primary,
              ),
            ),
            Text(
              'Profit: ${DateHelpers.formatCurrency(sale.profit)}',
              style: const TextStyle(fontSize: 11, color: AppTheme.success),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
