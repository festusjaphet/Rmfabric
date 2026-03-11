import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class ProductModel {
  final String productId;
  final String name;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final double stockQty;
  final bool active;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    required this.stockQty,
    required this.active,
    required this.createdAt,
  });

  double get margin => sellingPrice - costPrice;
  double get marginPercent =>
      sellingPrice > 0 ? (margin / sellingPrice) * 100 : 0;
  bool get isLowStock => stockQty > 0 && stockQty <= lowStockThreshold;
  bool get isOutOfStock => stockQty <= 0;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Other',
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      stockQty: (data['stockQty'] ?? 0).toDouble(),
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'category': category,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'stockQty': stockQty,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProductModel copyWith({
    String? name,
    String? category,
    double? sellingPrice,
    double? costPrice,
    double? stockQty,
    bool? active,
  }) {
    return ProductModel(
      productId: productId,
      name: name ?? this.name,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      stockQty: stockQty ?? this.stockQty,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
