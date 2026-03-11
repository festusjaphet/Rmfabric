import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sales_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/sale_model.dart';
import '../../widgets/sale_card.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Sales'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'This Week'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
          ),
        ),
        body: const TabBarView(
          children: [_TodaySalesTab(), _ThisWeekSalesTab()],
        ),
      ),
    );
  }
}

class _TodaySalesTab extends StatelessWidget {
  const _TodaySalesTab();

  @override
  Widget build(BuildContext context) {
    final salesProv = Provider.of<SalesProvider>(context);

    if (salesProv.todaySales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No sales recorded today',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primary.withValues(alpha: 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${salesProv.todayTransactionCount} transactions',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
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
            itemBuilder: (ctx, i) => SaleCard(sale: salesProv.todaySales[i]),
          ),
        ),
      ],
    );
  }
}

class _ThisWeekSalesTab extends StatefulWidget {
  const _ThisWeekSalesTab();

  @override
  State<_ThisWeekSalesTab> createState() => _ThisWeekSalesTabState();
}

class _ThisWeekSalesTabState extends State<_ThisWeekSalesTab> {
  late Future<List<SaleModel>> _weekFuture;
  late final String _sellerId;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    _sellerId = auth.currentUser!.userId;
    _loadData();
  }

  void _loadData() {
    final salesProv = Provider.of<SalesProvider>(context, listen: false);
    // Fetch all sales for this week, then filter by this seller.
    _weekFuture = salesProv.fetchWeeklySales(DateTime.now()).then((allSales) {
      return allSales.where((s) => s.sellerId == _sellerId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SaleModel>>(
      future: _weekFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: AppTheme.danger,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load sales'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadData();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final sales = snapshot.data ?? [];

        if (sales.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_view_week,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 12),
                Text(
                  'No sales recorded this week',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        final double totalSales = sales.fold(0.0, (s, e) => s + e.totalSale);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primary.withValues(alpha: 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sales.length} transactions',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Tsh ${totalSales.toStringAsFixed(2)}',
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
                itemCount: sales.length,
                itemBuilder: (ctx, i) => SaleCard(sale: sales[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}
