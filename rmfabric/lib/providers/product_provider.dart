import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;

  List<ProductModel> _products = [];
  bool _loading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get loading => _loading;
  String? get error => _error;

  ProductProvider(this._repo) {
    _watchProducts();
  }

  void _watchProducts() {
    _repo.watchProducts().listen(
      (list) {
        _products = list;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addProduct({
    required String name,
    required double sellingPrice,
    required double costPrice,
  }) async {
    _error = null;
    try {
      await _repo.addProduct(
        name: name,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateProduct(String productId) async {
    _error = null;
    try {
      await _repo.deactivateProduct(productId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
