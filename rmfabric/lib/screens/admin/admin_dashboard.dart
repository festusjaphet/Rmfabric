import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/date_helpers.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/sales_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/chart_widget.dart';
import 'products_screen.dart';
import 'expenses_screen.dart';
import 'sales_history_admin_screen.dart';
import 'daily_reports_screen.dart';
import 'weekly_reports_screen.dart';
import 'monthly_reports_screen.dart';
import 'custom_reports_screen.dart';
import 'close_day_screen.dart';
import 'stock_screen.dart';
import 'users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).init(null);
      // Only admins reach this screen — safe to start the RM_reports_daily stream.
      Provider.of<ReportProvider>(context, listen: false).initAdminStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final salesProv = Provider.of<SalesProvider>(context);
    final expProv = Provider.of<ExpenseProvider>(context);
    final reportProv = Provider.of<ReportProvider>(context);
    final stockProv = Provider.of<StockProvider>(context);

    final todayProfit = salesProv.todayTotalProfit - expProv.todayTotalExpenses;
    final lowStockCount =
        stockProv.outOfStock.length + stockProv.lowStock.length;

    // Build chart data from last 7 daily reports
    final dailyReports = reportProv.recentDailyReports;
    final labels = dailyReports
        .map((r) => r.date.substring(5))
        .toList()
        .reversed
        .toList();
    final salesData = dailyReports
        .map((r) => r.totalSales)
        .toList()
        .reversed
        .toList();
    final expData = dailyReports
        .map((r) => r.totalExpenses)
        .toList()
        .reversed
        .toList();
    final profitData = dailyReports
        .map((r) => r.totalProfit)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RM Fabrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Provider.of<app_auth.AuthProvider>(
                context,
                listen: false,
              ).signOut();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Welcome, ${auth.currentUser?.name.split(' ').first ?? 'Admin'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (reportProv.isDayClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DAY CLOSED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    DateHelpers.formatDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  DashboardStatCard(
                    title: 'Today Sales',
                    amount: salesProv.todayTotalSales,
                    icon: Icons.point_of_sale,
                    color: AppTheme.primary,
                  ),
                  DashboardStatCard(
                    title: 'Today Expenses',
                    amount: expProv.todayTotalExpenses,
                    icon: Icons.receipt_long,
                    color: AppTheme.danger,
                  ),
                  DashboardStatCard(
                    title: 'Product Cost',
                    amount: salesProv.todayTotalCost,
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.warning,
                  ),
                  DashboardStatCard(
                    title: 'Net Profit',
                    amount: todayProfit,
                    icon: Icons.trending_up,
                    color: AppTheme.success,
                    isProfit: true,
                  ),
                ],
              ),
            ),
          ),

          // Charts
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: ProfitLineChart(
                salesData: salesData.cast<double>(),
                expenseData: expData.cast<double>(),
                profitData: profitData.cast<double>(),
                labels: labels,
              ),
            ),
          ),

          // Low-stock alert banner
          if (lowStockCount > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StockScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppTheme.warning,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$lowStockCount product(s) need restocking  →',
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Quick Nav
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate(
                _menuItems(context, reportProv.isDayClosed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReopenDay(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen Day?'),
        content: const Text(
          'Are you sure you want to reopen today? Sellers will be able to record new sales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reopen'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final reportProv = Provider.of<ReportProvider>(context, listen: false);
      final success = await reportProv.openDay(
        adminId: auth.currentUser!.userId,
      );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Day has been reopened successfully.')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reportProv.error ?? 'Failed to reopen day')),
        );
      }
    }
  }

  List<Widget> _menuItems(BuildContext context, bool isDayClosed) {
    final items = [
      _NavTile(
        'Products',
        Icons.inventory_2,
        AppTheme.primary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        ),
      ),
      _NavTile(
        'Expenses',
        Icons.receipt_long,
        AppTheme.danger,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpensesScreen()),
        ),
      ),
      _NavTile(
        'Sales',
        Icons.shopping_bag,
        AppTheme.primaryLight,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalesHistoryAdminScreen()),
        ),
      ),
      _NavTile(
        'Daily',
        Icons.today,
        AppTheme.success,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyReportsScreen()),
        ),
      ),
      _NavTile(
        'Weekly',
        Icons.calendar_view_week,
        AppTheme.warning,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WeeklyReportsScreen()),
        ),
      ),
      _NavTile(
        'Monthly',
        Icons.calendar_month,
        Colors.teal,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonthlyReportsScreen()),
        ),
      ),
      _NavTile(
        'Custom',
        Icons.date_range,
        Colors.purple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomReportsScreen()),
        ),
      ),
      _NavTile(
        'Stock',
        Icons.warehouse_outlined,
        Colors.indigo,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StockScreen()),
        ),
      ),
      _NavTile(
        'Users',
        Icons.manage_accounts,
        Colors.deepPurple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsersScreen()),
        ),
      ),
      if (isDayClosed)
        _NavTile(
          'Reopen Day',
          Icons.lock_open,
          AppTheme.warning,
          () => _confirmReopenDay(context),
        )
      else
        _NavTile(
          'Close Day',
          Icons.lock_clock,
          AppTheme.danger,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CloseDayScreen()),
          ),
        ),
    ];
    return items;
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavTile(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
