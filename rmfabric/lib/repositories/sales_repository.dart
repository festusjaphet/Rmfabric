import 'package:uuid/uuid.dart';
import '../core/helpers/date_helpers.dart';
import '../models/sale_model.dart';
import '../models/report_model.dart';
import '../models/stock_movement_model.dart';
import '../services/firestore_service.dart';

class SalesRepository {
  final FirestoreService _firestoreService;

  SalesRepository(this._firestoreService);

  /// Record a new sale — calculates all derived fields
  Future<void> recordSale({
    required String productId,
    required String productName,
    required double quantity,
    required double sellingPrice,
    required double costPrice,
    required String sellerId,
    required String sellerName,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final totalSale = quantity * sellingPrice;
    final totalCost = quantity * costPrice;
    final profit = totalSale - totalCost;

    final sale = SaleModel(
      saleId: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      totalSale: totalSale,
      totalCost: totalCost,
      profit: profit,
      sellerId: sellerId,
      sellerName: sellerName,
      paymentMethod: paymentMethod,
      dayId: DateHelpers.dayId(now),
      weekId: DateHelpers.weekId(now),
      monthId: DateHelpers.monthId(now),
      createdAt: now,
    );

    await _firestoreService.addSale(sale);

    // Deduct stock atomically
    await _firestoreService.adjustStockQty(productId, -quantity);

    // Record the stock movement
    final movement = StockMovementModel(
      movementId: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantityChange: -quantity,
      reason: 'sale',
      createdBy: sellerId,
      createdAt: now,
    );
    await _firestoreService.addStockMovement(movement);
  }

  Stream<List<SaleModel>> watchTodaySales() =>
      _firestoreService.salesByDayStream(DateHelpers.dayId(DateTime.now()));

  Stream<List<SaleModel>> watchSellerTodaySales(String sellerId) =>
      _firestoreService.salesBySellerAndDayStream(
        sellerId,
        DateHelpers.dayId(DateTime.now()),
      );

  Future<List<SaleModel>> fetchWeeklySales(DateTime date) =>
      _firestoreService.getSalesByWeekId(DateHelpers.weekId(date));

  Future<List<SaleModel>> fetchMonthlySales(DateTime date) =>
      _firestoreService.getSalesByMonthId(DateHelpers.monthId(date));

  Future<List<SaleModel>> fetchSalesByDateRange(DateTime start, DateTime end) =>
      _firestoreService.getSalesByDateRange(start, end);

  /// Get day status to validate if day is open before recording
  Future<DayStatusModel?> getDayStatus(String dayId) =>
      _firestoreService.getDayStatus(dayId);
}
