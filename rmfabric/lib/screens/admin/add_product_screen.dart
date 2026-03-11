import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _sellingCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  String _category = productCategories.first;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sellingCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final success = await Provider.of<ProductProvider>(context, listen: false)
        .addProduct(
          name: _nameCtrl.text,
          category: _category,
          sellingPrice: double.parse(_sellingCtrl.text),
          costPrice: double.parse(_costCtrl.text),
          initialStock: double.parse(_stockCtrl.text),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added ✅'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add product'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selling = double.tryParse(_sellingCtrl.text) ?? 0;
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final margin = selling - cost;
    final marginPct = selling > 0 ? (margin / selling * 100) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter product name'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: productCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellingCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (Tsh)',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (Tsh)',
                        prefixIcon: Icon(Icons.price_check_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // Live margin preview
              if (selling > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: margin >= 0
                        ? AppTheme.success.withValues(alpha: 0.08)
                        : AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profit Margin:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Tsh ${margin.toStringAsFixed(2)}  (${marginPct.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: margin >= 0
                              ? AppTheme.success
                              : AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Initial Stock Quantity',
                  prefixIcon: Icon(Icons.warehouse_outlined),
                  helperText: 'How many units do you have in stock?',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
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
                      : const Icon(Icons.add),
                  label: Text(_loading ? 'Saving...' : 'Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
