import 'dart:async';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repo;
  StreamSubscription? _statusSub;
  StreamSubscription? _reportsSub;

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
    // Always watch today's day-status — sellers need this to know if
    // sales are locked for the day. RM_days allows read for all auth users.
    _statusSub = _repo.watchTodayStatus().listen((status) {
      _todayStatus = status;
      notifyListeners();
    });
    // RM_reports_daily is admin-only in Firestore rules.
    // Do NOT subscribe here — would cause PERMISSION_DENIED for seller accounts.
    // Call initAdminStreams() explicitly from the admin dashboard.
  }

  /// Must be called ONLY after confirming the user is an admin.
  /// Starts the RM_reports_daily real-time stream for the chart + daily list.
  void initAdminStreams() {
    _reportsSub?.cancel();
    _reportsSub = _repo.watchRecentDailyReports().listen((reports) {
      _recentDailyReports = reports;
      notifyListeners();
    });
  }

  void clear() {
    _statusSub?.cancel();
    _reportsSub?.cancel();
    _statusSub = null;
    _reportsSub = null;
    _todayStatus = null;
    _currentReport = null;
    _recentDailyReports = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _reportsSub?.cancel();
    super.dispose();
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

  Future<bool> openDay({required String adminId}) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.openDay(adminId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
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
