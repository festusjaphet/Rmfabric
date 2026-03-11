import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';

class SalesProvider extends ChangeNotifier {
  final SalesRepository _repo;
  StreamSubscription? _sub;

  List<SaleModel> _todaySales = [];
  bool _loading = false;
  bool _isDayClosed = false;
  String? _error;

  List<SaleModel> get todaySales => _todaySales;
  bool get loading => _loading;
  bool get isDayClosed => _isDayClosed;
  String? get error => _error;

  double get todayTotalSales =>
      _todaySales.fold(0.0, (s, e) => s + e.totalSale);
  double get todayTotalCost => _todaySales.fold(0.0, (s, e) => s + e.totalCost);
  double get todayTotalProfit => _todaySales.fold(0.0, (s, e) => s + e.profit);
  int get todayTransactionCount => _todaySales.length;

  SalesProvider(this._repo);

  void init(String? sellerId) {
    _sub?.cancel();
    if (sellerId != null) {
      _sub = _repo
          .watchSellerTodaySales(sellerId)
          .listen(_updateSales, onError: _onError);
    } else {
      _sub = _repo.watchTodaySales().listen(_updateSales, onError: _onError);
    }
  }

  void clear() {
    _sub?.cancel();
    _sub = null;
    _todaySales = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _updateSales(List<SaleModel> sales) {
    _todaySales = sales;
    notifyListeners();
  }

  void _onError(dynamic e) {
    _error = e.toString();
    notifyListeners();
  }

  Future<bool> recordSale({
    required String productId,
    required String productName,
    required double quantity,
    required double sellingPrice,
    required double costPrice,
    required String sellerId,
    required String sellerName,
    required String paymentMethod,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.recordSale(
        productId: productId,
        productName: productName,
        quantity: quantity,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        sellerId: sellerId,
        sellerName: sellerName,
        paymentMethod: paymentMethod,
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

  Future<List<SaleModel>> fetchWeeklySales(DateTime date) =>
      _repo.fetchWeeklySales(date);

  Future<List<SaleModel>> fetchMonthlySales(DateTime date) =>
      _repo.fetchMonthlySales(date);

  Future<List<SaleModel>> fetchCustomRangeSales(DateTime start, DateTime end) =>
      _repo.fetchSalesByDateRange(start, end);
}
