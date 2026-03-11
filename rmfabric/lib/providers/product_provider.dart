import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  StreamSubscription? _sub;

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
    _sub?.cancel();
    _sub = _repo.watchProducts().listen(
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

  void clear() {
    _sub?.cancel();
    _sub = null;
    _products = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<bool> addProduct({
    required String name,
    required String category,
    required double sellingPrice,
    required double costPrice,
    required double initialStock,
  }) async {
    _error = null;
    try {
      await _repo.addProduct(
        name: name,
        category: category,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        initialStock: initialStock,
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
