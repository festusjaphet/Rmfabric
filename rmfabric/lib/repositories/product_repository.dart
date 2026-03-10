import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepository(this._firestoreService);

  Stream<List<ProductModel>> watchProducts({bool activeOnly = true}) =>
      _firestoreService.productsStream(activeOnly: activeOnly);

  Future<void> addProduct({
    required String name,
    required double sellingPrice,
    required double costPrice,
  }) async {
    final product = ProductModel(
      productId: const Uuid().v4(),
      name: name.trim(),
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      active: true,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addProduct(product);
  }

  Future<void> updateProduct(ProductModel product) =>
      _firestoreService.updateProduct(product);

  Future<void> deactivateProduct(String productId) =>
      _firestoreService.deactivateProduct(productId);
}
