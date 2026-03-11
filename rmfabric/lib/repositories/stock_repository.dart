import 'package:uuid/uuid.dart';
import '../models/stock_movement_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class StockRepository {
  final FirestoreService _db;

  StockRepository(this._db);

  Stream<List<ProductModel>> watchAllProducts() =>
      _db.productsStream(activeOnly: false);

  Stream<List<StockMovementModel>> watchAllMovements() =>
      _db.recentStockMovements();

  Stream<List<StockMovementModel>> watchMovementsForProduct(String productId) =>
      _db.stockMovementsForProduct(productId);

  /// Restock a product: increase stockQty and record a movement
  Future<void> restockProduct({
    required String productId,
    required String productName,
    required double quantity,
    required String adminId,
  }) async {
    // Adjust the stock count atomically
    await _db.adjustStockQty(productId, quantity);

    // Record the movement
    final movement = StockMovementModel(
      movementId: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantityChange: quantity,
      reason: 'restock',
      createdBy: adminId,
      createdAt: DateTime.now(),
    );
    await _db.addStockMovement(movement);
  }

  /// Manual adjustment (positive or negative)
  Future<void> adjustStock({
    required String productId,
    required String productName,
    required double delta,
    required String reason,
    required String adminId,
  }) async {
    await _db.adjustStockQty(productId, delta);
    final movement = StockMovementModel(
      movementId: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantityChange: delta,
      reason: reason,
      createdBy: adminId,
      createdAt: DateTime.now(),
    );
    await _db.addStockMovement(movement);
  }
}
