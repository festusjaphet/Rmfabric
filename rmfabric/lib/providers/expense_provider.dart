import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo;
  StreamSubscription? _sub;

  List<ExpenseModel> _todayExpenses = [];
  bool _loading = false;
  String? _error;

  List<ExpenseModel> get todayExpenses => _todayExpenses;
  bool get loading => _loading;
  String? get error => _error;

  double get todayTotalExpenses =>
      _todayExpenses.fold(0.0, (s, e) => s + e.amount);

  ExpenseProvider(this._repo) {
    _sub = _repo.watchTodayExpenses().listen(
      (list) {
        _todayExpenses = list;
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
    _todayExpenses = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<bool> addExpense({
    required String title,
    required String category,
    required double amount,
    required String note,
    required String createdBy,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.addExpense(
        title: title,
        category: category,
        amount: amount,
        note: note,
        createdBy: createdBy,
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

  Future<List<ExpenseModel>> fetchWeeklyExpenses(DateTime date) =>
      _repo.fetchWeeklyExpenses(date);

  Future<List<ExpenseModel>> fetchMonthlyExpenses(DateTime date) =>
      _repo.fetchMonthlyExpenses(date);

  Future<List<ExpenseModel>> fetchCustomRangeExpenses(
    DateTime start,
    DateTime end,
  ) => _repo.fetchExpensesByDateRange(start, end);
}
