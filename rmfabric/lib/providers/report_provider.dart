import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repo;

  DayStatusModel? _todayStatus;
  PeriodReportModel? _currentReport;
  List<DailyReportModel> _recentDailyReports = [];
  bool _loading = false;
  bool _closingDay = false;
  String? _error;

  DayStatusModel? get todayStatus => _todayStatus;
  PeriodReportModel? get currentReport => _currentReport;
  List<DailyReportModel> get recentDailyReports => _recentDailyReports;
  bool get loading => _loading;
  bool get closingDay => _closingDay;
  bool get isDayClosed => _todayStatus?.isClosed ?? false;
  String? get error => _error;

  ReportProvider(this._repo) {
    _repo.watchTodayStatus().listen((status) {
      _todayStatus = status;
      notifyListeners();
    });
    _repo.watchRecentDailyReports().listen((reports) {
      _recentDailyReports = reports;
      notifyListeners();
    });
  }

  Future<bool> closeDay({
    required String adminId,
    required List<SaleModel> sales,
    required List<ExpenseModel> expenses,
  }) async {
    _error = null;
    _closingDay = true;
    notifyListeners();
    try {
      await _repo.closeDay(adminId: adminId, sales: sales, expenses: expenses);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _closingDay = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyReport(DateTime date) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentReport = await _repo.getWeeklyReport(date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyReport(DateTime date) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentReport = await _repo.getMonthlyReport(date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomReport(DateTime start, DateTime end) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentReport = await _repo.getCustomReport(start, end);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
