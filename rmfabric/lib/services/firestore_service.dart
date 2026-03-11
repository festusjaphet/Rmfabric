import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../models/stock_movement_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── PRODUCTS ────────────────────────────────────────────────────────────────

  CollectionReference get _productsCol => _db.collection(colProducts);

  Stream<List<ProductModel>> productsStream({bool activeOnly = true}) {
    Query q = _productsCol.orderBy('name');
    if (activeOnly) q = q.where('active', isEqualTo: true);
    return q.snapshots().map(
      (s) => s.docs.map((d) => ProductModel.fromFirestore(d)).toList(),
    );
  }

  Future<void> addProduct(ProductModel product) async {
    await _productsCol.doc(product.productId).set(product.toFirestore());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _productsCol.doc(product.productId).update(product.toFirestore());
  }

  Future<void> deactivateProduct(String productId) async {
    await _productsCol.doc(productId).update({'active': false});
  }

  // ─── SALES ───────────────────────────────────────────────────────────────────

  CollectionReference get _salesCol => _db.collection(colSales);

  Future<void> addSale(SaleModel sale) async {
    await _salesCol.doc(sale.saleId).set(sale.toFirestore());
  }

  Stream<List<SaleModel>> salesByDayStream(String dayId) {
    return _salesCol
        .where('dayId', isEqualTo: dayId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }

  Stream<List<SaleModel>> salesBySellerAndDayStream(
    String sellerId,
    String dayId,
  ) {
    return _salesCol
        .where('sellerId', isEqualTo: sellerId)
        .where('dayId', isEqualTo: dayId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }

  Future<List<SaleModel>> getSalesByWeekId(String weekId) async {
    final snap = await _salesCol.where('weekId', isEqualTo: weekId).get();
    return snap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
  }

  Future<List<SaleModel>> getSalesByMonthId(String monthId) async {
    final snap = await _salesCol.where('monthId', isEqualTo: monthId).get();
    return snap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
  }

  Future<List<SaleModel>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _salesCol
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
  }

  // ─── EXPENSES ────────────────────────────────────────────────────────────────

  CollectionReference get _expensesCol => _db.collection(colExpenses);

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesCol.doc(expense.expenseId).set(expense.toFirestore());
  }

  Stream<List<ExpenseModel>> expensesByDayStream(String dayId) {
    return _expensesCol
        .where('dayId', isEqualTo: dayId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ExpenseModel.fromFirestore(d)).toList());
  }

  Future<List<ExpenseModel>> getExpensesByWeekId(String weekId) async {
    final snap = await _expensesCol.where('weekId', isEqualTo: weekId).get();
    return snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByMonthId(String monthId) async {
    final snap = await _expensesCol.where('monthId', isEqualTo: monthId).get();
    return snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _expensesCol
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList();
  }

  // ─── DAYS ─────────────────────────────────────────────────────────────────────

  Future<DayStatusModel?> getDayStatus(String dayId) async {
    final doc = await _db.collection(colDays).doc(dayId).get();
    if (!doc.exists) return null;
    return DayStatusModel.fromFirestore(doc);
  }

  Stream<DayStatusModel?> dayStatusStream(String dayId) {
    return _db.collection(colDays).doc(dayId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DayStatusModel.fromFirestore(doc);
    });
  }

  Future<void> saveDayStatus(DayStatusModel day) async {
    await _db.collection(colDays).doc(day.date).set(day.toFirestore());
  }

  // ─── DAILY REPORTS ────────────────────────────────────────────────────────────

  Future<void> saveDailyReport(DailyReportModel report) async {
    await _db
        .collection(colReportsDaily)
        .doc(report.date)
        .set(report.toFirestore());
  }

  Future<DailyReportModel?> getDailyReport(String date) async {
    final doc = await _db.collection(colReportsDaily).doc(date).get();
    if (!doc.exists) return null;
    return DailyReportModel.fromFirestore(doc);
  }

  Stream<List<DailyReportModel>> recentDailyReportsStream({int limit = 7}) {
    return _db
        .collection(colReportsDaily)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => DailyReportModel.fromFirestore(d)).toList(),
        );
  }

  // ─── USERS ────────────────────────────────────────────────────────────────────

  Stream<List<UserModel>> usersStream() {
    return _db
        .collection(colUsers)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<void> updateUserStatus(String userId, bool active) async {
    await _db.collection(colUsers).doc(userId).update({'active': active});
  }

  // ─── STOCK MOVEMENTS ─────────────────────────────────────────────────────────

  CollectionReference get _stockCol => _db.collection(colStockMovements);

  Future<void> addStockMovement(StockMovementModel movement) async {
    await _stockCol.doc(movement.movementId).set(movement.toFirestore());
  }

  Stream<List<StockMovementModel>> stockMovementsForProduct(String productId) {
    return _stockCol
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => StockMovementModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<StockMovementModel>> recentStockMovements({int limit = 50}) {
    return _stockCol
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => StockMovementModel.fromFirestore(d)).toList(),
        );
  }

  /// Atomically decrease / increase stockQty on RM_products
  Future<void> adjustStockQty(String productId, double deltaQty) async {
    final ref = _db.collection(colProducts).doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      final current = (data?['stockQty'] ?? 0).toDouble();
      tx.update(ref, {'stockQty': current + deltaQty});
    });
  }
}
