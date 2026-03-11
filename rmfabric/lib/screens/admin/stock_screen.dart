import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/stock_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProv = Provider.of<StockProvider>(context);
    final auth = Provider.of<app_auth.AuthProvider>(context);

    final allCategories = ['All', ...productCategories];
    final filtered = _filterCategory == 'All'
        ? stockProv.allProducts
        : stockProv.allProducts
              .where((p) => p.category == _filterCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Tracker'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Inventory', icon: Icon(Icons.warehouse_outlined)),
            Tab(text: 'Movements', icon: Icon(Icons.swap_vert)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Tab 1: Inventory ─────────────────────────────────────────────
          Column(
            children: [
              // Alerts row
              if (stockProv.outOfStock.isNotEmpty ||
                  stockProv.lowStock.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  color: AppTheme.danger.withValues(alpha: 0.07),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: AppTheme.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${stockProv.outOfStock.length} out of stock  •  '
                        '${stockProv.lowStock.length} low stock',
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Category filter chips
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: allCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final cat = allCategories[i];
                    final selected = cat == _filterCategory;
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterCategory = cat),
                      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                    );
                  },
                ),
              ),

              // Product list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No products',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final p = filtered[i];
                          Color stockColor = AppTheme.success;
                          String stockLabel = '${p.stockQty} units';
                          if (p.isOutOfStock) {
                            stockColor = AppTheme.danger;
                            stockLabel = 'OUT OF STOCK';
                          } else if (p.isLowStock) {
                            stockColor = AppTheme.warning;
                            stockLabel = '${p.stockQty} — LOW';
                          }

                          return Card(
                            child: ListTile(
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: stockColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: stockColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${p.category}  •  Tsh ${p.sellingPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    stockLabel,
                                    style: TextStyle(
                                      color: stockColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showRestockDialog(
                                      context,
                                      p,
                                      auth,
                                      stockProv,
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 20),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Restock',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ── Tab 2: Stock Movements ───────────────────────────────────────
          stockProv.movements.isEmpty
              ? const Center(
                  child: Text(
                    'No movements recorded yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: stockProv.movements.length,
                  itemBuilder: (ctx, i) {
                    final m = stockProv.movements[i];
                    final isPositive = m.quantityChange > 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPositive
                              ? AppTheme.success.withValues(alpha: 0.12)
                              : AppTheme.danger.withValues(alpha: 0.12),
                          child: Icon(
                            isPositive
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: isPositive
                                ? AppTheme.success
                                : AppTheme.danger,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          m.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${m.reason.toUpperCase()}  •  ${m.createdAt.day}/${m.createdAt.month}/${m.createdAt.year}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          '${isPositive ? '+' : ''}${m.quantityChange}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isPositive
                                ? AppTheme.success
                                : AppTheme.danger,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Future<void> _showRestockDialog(
    BuildContext context,
    dynamic product,
    app_auth.AuthProvider auth,
    StockProvider stockProv,
  ) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Restock ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current stock: ${product.stockQty} units',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                prefixIcon: Icon(Icons.add),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restock'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final qty = double.tryParse(ctrl.text) ?? 0.0;
      if (qty > 0) {
        final ok = await stockProv.restock(
          productId: product.productId,
          productName: product.name,
          quantity: qty,
          adminId: auth.currentUser?.userId ?? '',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok ? 'Restocked $qty units ✅' : 'Failed to restock',
              ),
              backgroundColor: ok ? AppTheme.success : AppTheme.danger,
            ),
          );
        }
      }
    }
  }
}
