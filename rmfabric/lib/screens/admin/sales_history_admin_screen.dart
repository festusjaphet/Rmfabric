import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/sale_card.dart';

class SalesHistoryAdminScreen extends StatelessWidget {
  const SalesHistoryAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesProv = Provider.of<SalesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Sales')),
      body: salesProv.todaySales.isEmpty
          ? const Center(
              child: Text(
                'No sales today',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${salesProv.todayTransactionCount} transactions',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Tsh ${salesProv.todayTotalSales.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: salesProv.todaySales.length,
                    itemBuilder: (ctx, i) =>
                        SaleCard(sale: salesProv.todaySales[i]),
                  ),
                ),
              ],
            ),
    );
  }
}
