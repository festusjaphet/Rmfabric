import 'package:uuid/uuid.dart';
import '../core/helpers/date_helpers.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseRepository {
  final FirestoreService _firestoreService;

  ExpenseRepository(this._firestoreService);

  Future<void> addExpense({
    required String title,
    required String category,
    required double amount,
    required String note,
    required String createdBy,
  }) async {
    final now = DateTime.now();
    final expense = ExpenseModel(
      expenseId: const Uuid().v4(),
      title: title.trim(),
      category: category,
      amount: amount,
      note: note.trim(),
      createdBy: createdBy,
      dayId: DateHelpers.dayId(now),
      weekId: DateHelpers.weekId(now),
      monthId: DateHelpers.monthId(now),
      createdAt: now,
    );
    await _firestoreService.addExpense(expense);
  }

  Stream<List<ExpenseModel>> watchTodayExpenses() =>
      _firestoreService.expensesByDayStream(DateHelpers.dayId(DateTime.now()));

  Future<List<ExpenseModel>> fetchWeeklyExpenses(DateTime date) =>
      _firestoreService.getExpensesByWeekId(DateHelpers.weekId(date));

  Future<List<ExpenseModel>> fetchMonthlyExpenses(DateTime date) =>
      _firestoreService.getExpensesByMonthId(DateHelpers.monthId(date));

  Future<List<ExpenseModel>> fetchExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) => _firestoreService.getExpensesByDateRange(start, end);
}
