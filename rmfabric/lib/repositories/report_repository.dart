import '../core/helpers/date_helpers.dart';
import '../models/report_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ReportRepository {
  final FirestoreService _firestoreService;

  ReportRepository(this._firestoreService);

  // ─── DAY STATUS ─────────────────────────────────────────────────────────────

  Stream<DayStatusModel?> watchTodayStatus() =>
      _firestoreService.dayStatusStream(DateHelpers.dayId(DateTime.now()));

  Future<DayStatusModel?> getTodayStatus() =>
      _firestoreService.getDayStatus(DateHelpers.dayId(DateTime.now()));

  /// Close the day: aggregate all sales/expenses, save report + update day status
  Future<void> closeDay({
    required String adminId,
    required List<SaleModel> sales,
    required List<ExpenseModel> expenses,
  }) async {
    final today = DateTime.now();
    final dayId = DateHelpers.dayId(today);

    final totalSales = sales.fold(0.0, (s, e) => s + e.totalSale);
    final totalCost = sales.fold(0.0, (s, e) => s + e.totalCost);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);
    final totalProfit = totalSales - totalCost - totalExpenses;

    // Save to RM_reports_daily
    final dailyReport = DailyReportModel(
      date: dayId,
      totalSales: totalSales,
      totalCost: totalCost,
      totalExpenses: totalExpenses,
      totalProfit: totalProfit,
      totalTransactions: sales.length,
      closedBy: adminId,
      closedAt: today,
    );
    await _firestoreService.saveDailyReport(dailyReport);

    // Update RM_days
    final dayStatus = DayStatusModel(
      date: dayId,
      isClosed: true,
      closedBy: adminId,
      closedAt: today,
      totalSales: totalSales,
      totalCost: totalCost,
      totalExpenses: totalExpenses,
      totalProfit: totalProfit,
    );
    await _firestoreService.saveDayStatus(dayStatus);
  }

  // ─── DAILY REPORTS ──────────────────────────────────────────────────────────

  Future<DailyReportModel?> getDailyReport(String date) =>
      _firestoreService.getDailyReport(date);

  Stream<List<DailyReportModel>> watchRecentDailyReports({int limit = 7}) =>
      _firestoreService.recentDailyReportsStream(limit: limit);

  // ─── WEEKLY AGGREGATE ───────────────────────────────────────────────────────

  Future<PeriodReportModel> getWeeklyReport(DateTime date) async {
    final sales = await _firestoreService.getSalesByWeekId(
      DateHelpers.weekId(date),
    );
    final expenses = await _firestoreService.getExpensesByWeekId(
      DateHelpers.weekId(date),
    );

    return _aggregate(
      periodId: DateHelpers.weekId(date),
      sales: sales,
      expenses: expenses,
    );
  }

  // ─── MONTHLY AGGREGATE ──────────────────────────────────────────────────────

  Future<PeriodReportModel> getMonthlyReport(DateTime date) async {
    final sales = await _firestoreService.getSalesByMonthId(
      DateHelpers.monthId(date),
    );
    final expenses = await _firestoreService.getExpensesByMonthId(
      DateHelpers.monthId(date),
    );

    return _aggregate(
      periodId: DateHelpers.monthId(date),
      sales: sales,
      expenses: expenses,
    );
  }

  // ─── CUSTOM DATE RANGE ──────────────────────────────────────────────────────

  Future<PeriodReportModel> getCustomReport(
    DateTime start,
    DateTime end,
  ) async {
    final sales = await _firestoreService.getSalesByDateRange(start, end);
    final expenses = await _firestoreService.getExpensesByDateRange(start, end);

    return _aggregate(
      periodId:
          '${DateHelpers.formatDate(start)} - ${DateHelpers.formatDate(end)}',
      sales: sales,
      expenses: expenses,
    );
  }

  // ─── HELPER ─────────────────────────────────────────────────────────────────

  PeriodReportModel _aggregate({
    required String periodId,
    required List<SaleModel> sales,
    required List<ExpenseModel> expenses,
  }) {
    final totalSales = sales.fold(0.0, (s, e) => s + e.totalSale);
    final totalCost = sales.fold(0.0, (s, e) => s + e.totalCost);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);
    final totalProfit = totalSales - totalCost - totalExpenses;

    return PeriodReportModel(
      periodId: periodId,
      totalSales: totalSales,
      totalCost: totalCost,
      totalExpenses: totalExpenses,
      totalProfit: totalProfit,
      totalTransactions: sales.length,
    );
  }
}
