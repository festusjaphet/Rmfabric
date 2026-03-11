import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/product_model.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  ProductModel? _selectedProduct;
  final _qtyCtrl = TextEditingController(text: '1');
  String _paymentMethod = 'Cash';
  bool _loading = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final reportProv = Provider.of<ReportProvider>(context, listen: false);
    if (reportProv.isDayClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Day is closed. No new sales allowed.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final salesProv = Provider.of<SalesProvider>(context, listen: false);

    final success = await salesProv.recordSale(
      productId: _selectedProduct!.productId,
      productName: _selectedProduct!.name,
      quantity: double.tryParse(_qtyCtrl.text) ?? 1.0,
      sellingPrice: _selectedProduct!.sellingPrice,
      costPrice: _selectedProduct!.costPrice,
      sellerId: auth.currentUser!.userId,
      sellerName: auth.currentUser!.name,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale recorded successfully! ✅'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(salesProv.error ?? 'Failed to record sale'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;
    print("====products: $products");

    return Scaffold(
      appBar: AppBar(title: const Text('Record New Sale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product dropdown
              const Text(
                'Select Product',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ProductModel>(
                value: products.contains(_selectedProduct)
                    ? _selectedProduct
                    : null,
                hint: const Text('Choose a product'),
                decoration: const InputDecoration(),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedProduct = val),
                validator: (v) => v == null ? 'Please select a product' : null,
              ),

              // Pricing preview
              if (_selectedProduct != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priceInfo(
                        'Selling Price',
                        'Tsh ${_selectedProduct!.sellingPrice.toStringAsFixed(2)}',
                        AppTheme.primary,
                      ),
                      _priceInfo(
                        'Cost Price',
                        'Tsh ${_selectedProduct!.costPrice.toStringAsFixed(2)}',
                        AppTheme.warning,
                      ),
                      _priceInfo(
                        'Margin',
                        'Tsh ${_selectedProduct!.margin.toStringAsFixed(2)}',
                        AppTheme.success,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                'Quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.production_quantity_limits),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payment),
                ),
                items: paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              // Total preview
              if (_selectedProduct != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Sale',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'Tsh ${((double.tryParse(_qtyCtrl.text) ?? (_qtyCtrl.text.isEmpty ? 0.0 : 1.0)) * _selectedProduct!.sellingPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_loading ? 'Recording...' : 'Record Sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
