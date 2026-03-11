import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import '../repositories/stock_repository.dart';

class StockProvider extends ChangeNotifier {
  final StockRepository _repo;
  StreamSubscription? _prodSub;
  StreamSubscription? _movSub;

  List<ProductModel> _allProducts = [];
  List<StockMovementModel> _movements = [];
  bool _loading = false;
  String? _error;

  List<ProductModel> get allProducts => _allProducts;
  List<StockMovementModel> get movements => _movements;
  bool get loading => _loading;
  String? get error => _error;

  List<ProductModel> get outOfStock =>
      _allProducts.where((p) => p.isOutOfStock && p.active).toList();

  List<ProductModel> get lowStock =>
      _allProducts.where((p) => p.isLowStock && p.active).toList();

  StockProvider(this._repo) {
    _prodSub?.cancel();
    _prodSub = _repo.watchAllProducts().listen(
      (list) {
        _allProducts = list;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );

    _movSub?.cancel();
    _movSub = _repo.watchAllMovements().listen((list) {
      _movements = list;
      notifyListeners();
    });
  }

  void clear() {
    _prodSub?.cancel();
    _movSub?.cancel();
    _prodSub = null;
    _movSub = null;
    _allProducts = [];
    _movements = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _prodSub?.cancel();
    _movSub?.cancel();
    super.dispose();
  }

  Future<bool> restock({
    required String productId,
    required String productName,
    required double quantity,
    required String adminId,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.restockProduct(
        productId: productId,
        productName: productName,
        quantity: quantity,
        adminId: adminId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> adjustStock({
    required String productId,
    required String productName,
    required double delta,
    required String reason,
    required String adminId,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.adjustStock(
        productId: productId,
        productName: productName,
        delta: delta,
        reason: reason,
        adminId: adminId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
